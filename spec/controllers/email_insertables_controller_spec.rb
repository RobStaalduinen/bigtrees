require 'rails_helper'

RSpec.describe EmailInsertablesController, type: :controller do
  let(:organization) { create(:organization) }
  let(:arborist) { create(:arborist, :admin, organization: organization) }

  before do
    request.cookies[:session_token] = arborist.session_token
    request.headers['X-ORGANIZATION-ID'] = organization.id.to_s
  end

  describe 'GET #index' do
    it 'returns the organization insertables with their nested options' do
      insertable = create(:email_insertable, organization: organization, key: 'SCHEDULE_TEXT')
      create(:email_insertable_option, email_insertable: insertable, label: 'Next few days', position: 0)

      get :index, params: { format: :json }

      body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(body['email_insertables'].length).to eq(1)

      payload = body['email_insertables'].first
      expect(payload['key']).to eq('SCHEDULE_TEXT')
      expect(payload['label']).to eq('Add Schedule Text')
      expect(payload['options'].map { |o| o['label'] }).to eq(['Next few days'])
    end

    it 'preserves option content whitespace verbatim' do
      insertable = create(:email_insertable, organization: organization, key: 'SCHEDULE_TEXT')
      create(:email_insertable_option, email_insertable: insertable, content: "First line.\n\nSecond line.")

      get :index, params: { format: :json }

      option = JSON.parse(response.body)['email_insertables'].first['options'].first
      expect(option['content']).to eq("First line.\n\nSecond line.")
    end

    it 'does not return insertables belonging to another organization' do
      create(:email_insertable, organization: create(:organization), key: 'SCHEDULE_TEXT')

      get :index, params: { format: :json }

      expect(JSON.parse(response.body)['email_insertables']).to be_empty
    end

    it 'returns the reserved template keys alongside the insertables' do
      get :index, params: { format: :json }

      expect(JSON.parse(response.body)['reserved_keys']).to eq(EmailTemplate::RESERVED_KEYS)
    end
  end

  describe 'POST #create' do
    def post_create(attributes)
      post :create, params: { email_insertable: attributes }, as: :json
    end

    let(:valid_attributes) do
      {
        key: 'CALLOUT',
        label: 'Add Callout',
        options_attributes: [
          { label: 'Urgent', content: 'We can attend today.', position: 0 },
          { label: 'Relaxed', content: 'We can attend next month.', position: 1 }
        ]
      }
    end

    it 'creates the insertable with its options for the current organization' do
      expect { post_create(valid_attributes) }.to change(EmailInsertable, :count).by(1)

      expect(response).to have_http_status(:ok)

      insertable = EmailInsertable.last
      expect(insertable.organization).to eq(organization)
      expect(insertable.key).to eq('CALLOUT')
      expect(insertable.options.map(&:label)).to eq(%w[Urgent Relaxed])
    end

    it 'returns the created insertable under the serializer root' do
      post_create(valid_attributes)

      payload = JSON.parse(response.body)['email_insertable']
      expect(payload['key']).to eq('CALLOUT')
      expect(payload['options'].map { |o| o['label'] }).to eq(%w[Urgent Relaxed])
    end

    it 'normalizes the submitted key' do
      post_create(valid_attributes.merge(key: '[callout]'))

      expect(EmailInsertable.last.key).to eq('CALLOUT')
    end

    it 'rejects a key already used by the organization' do
      create(:email_insertable, organization: organization, key: 'CALLOUT')

      expect { post_create(valid_attributes) }.not_to change(EmailInsertable, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['key']).to be_present
    end

    it 'allows a key another organization already uses' do
      create(:email_insertable, organization: create(:organization), key: 'CALLOUT')

      expect { post_create(valid_attributes) }.to change(EmailInsertable, :count).by(1)
    end

    it 'rejects a reserved key' do
      post_create(valid_attributes.merge(key: 'FIRST_NAME'))

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['key']).to include('is reserved')
    end

    it 'rejects more than the maximum number of options' do
      options = (0..EmailInsertable::MAX_OPTIONS).map do |index|
        { label: "Option #{index}", content: 'Content', position: index }
      end

      expect { post_create(valid_attributes.merge(options_attributes: options)) }
        .not_to change(EmailInsertable, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['options']).to be_present
    end
  end

  describe 'PUT #update' do
    let!(:insertable) { create(:email_insertable, organization: organization, key: 'CALLOUT') }
    let!(:option) { create(:email_insertable_option, email_insertable: insertable, label: 'Urgent', position: 0) }

    def put_update(attributes, id: insertable.id)
      put :update, params: { id: id, email_insertable: attributes }, as: :json
    end

    it 'updates the key and label' do
      put_update({ key: 'NOTICE', label: 'Add Notice' })

      expect(response).to have_http_status(:ok)
      expect(insertable.reload.key).to eq('NOTICE')
      expect(insertable.label).to eq('Add Notice')
    end

    it 'updates an existing option in place' do
      put_update({ options_attributes: [{ id: option.id, label: 'Rewritten', content: 'New text.', position: 0 }] })

      expect(option.reload.label).to eq('Rewritten')
      expect(insertable.reload.options.count).to eq(1)
    end

    it 'adds a new option' do
      put_update({ options_attributes: [{ label: 'Relaxed', content: 'Next month.', position: 1 }] })

      expect(insertable.reload.options.map(&:label)).to eq(%w[Urgent Relaxed])
    end

    it 'removes an option flagged for destruction' do
      put_update({ options_attributes: [{ id: option.id, _destroy: true }] })

      expect(insertable.reload.options).to be_empty
    end

    it 'rejects an option that would push an untouched collection past the limit' do
      (EmailInsertable::MAX_OPTIONS - 1).times { create(:email_insertable_option, email_insertable: insertable) }

      put_update({ options_attributes: [{ label: 'One too many', content: 'Content' }] })

      expect(response).to have_http_status(:unprocessable_entity)
      expect(insertable.reload.options.count).to eq(EmailInsertable::MAX_OPTIONS)
    end

    it 'allows swapping an option once a removal makes room' do
      (EmailInsertable::MAX_OPTIONS - 1).times { create(:email_insertable_option, email_insertable: insertable) }

      put_update({ options_attributes: [{ id: option.id, _destroy: true }, { label: 'Replacement', content: 'Content' }] })

      expect(response).to have_http_status(:ok)
      expect(insertable.reload.options.count).to eq(EmailInsertable::MAX_OPTIONS)
      expect(insertable.options.map(&:label)).to include('Replacement')
      expect(insertable.options.map(&:label)).not_to include('Urgent')
    end

    it 'rejects a key another insertable in the organization already uses' do
      create(:email_insertable, organization: organization, key: 'NOTICE')

      put_update({ key: 'NOTICE' })

      expect(response).to have_http_status(:unprocessable_entity)
      expect(insertable.reload.key).to eq('CALLOUT')
    end

    it 'keeps its own key valid when nothing else changes' do
      put_update({ key: 'CALLOUT', label: 'Add Callout' })

      expect(response).to have_http_status(:ok)
    end

    it 'rejects a reserved key' do
      put_update({ key: 'SIGNATURE' })

      expect(response).to have_http_status(:unprocessable_entity)
      expect(insertable.reload.key).to eq('CALLOUT')
    end

    it 'does not update an insertable belonging to another organization' do
      other = create(:email_insertable, organization: create(:organization), key: 'CALLOUT')

      put_update({ label: 'Hijacked' }, id: other.id)

      expect(response).to have_http_status(:not_found)
      expect(other.reload.label).not_to eq('Hijacked')
    end
  end
end
