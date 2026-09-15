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
  end
end
