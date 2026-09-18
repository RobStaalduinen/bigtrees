require 'rails_helper'

RSpec.describe EmailTemplatesController, type: :controller do
  let(:organization) { create(:organization) }
  let(:arborist) { create(:arborist, :admin, organization: organization) }

  before do
    request.cookies[:session_token] = arborist.session_token
    request.headers['X-ORGANIZATION-ID'] = organization.id.to_s
  end

  describe 'GET #index' do
    it 'reports whether each template can be deleted' do
      organization.email_templates.create!(key: 'quote_mailout', subject: 'x', content: 'y', category: 'quote')
      organization.email_templates.create!(key: 'spring_promo', subject: 'x', content: 'y', category: 'quote')

      get :index, params: { format: :json }

      payload = JSON.parse(response.body)['email_templates'].index_by { |t| t['key'] }
      expect(payload['quote_mailout']['deletable']).to eq(false)
      expect(payload['spring_promo']['deletable']).to eq(true)
      expect(payload['spring_promo']['category']).to eq('quote')
    end
  end

  describe 'GET #show' do
    it 'returns the template for the edit page' do
      organization.email_templates.create!(key: 'spring_promo', subject: 'x', content: 'y', category: 'quote')

      get :show, params: { id: 'spring_promo', format: :json }

      payload = JSON.parse(response.body)['email_template']
      expect(response).to have_http_status(:ok)
      expect(payload['category']).to eq('quote')
    end

    it 'returns 404 for a key the organization does not have' do
      get :show, params: { id: 'nonexistent', format: :json }

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for a template belonging to another organization' do
      create(:organization).email_templates.create!(key: 'other_one', subject: 'x', content: 'y', category: 'quote')

      get :show, params: { id: 'other_one', format: :json }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    let(:base_params) do
      {
        email_template: {
          title: 'One Week Heads-Up',
          subject: 'See you soon',
          content: 'Hi [FIRST_NAME], we will see you next week.',
          category: 'scheduling'
        },
        format: :json
      }
    end

    it 'creates a scheduling template with a slugified key' do
      expect {
        post :create, params: base_params
      }.to change(EmailTemplate, :count).by(1)

      template = EmailTemplate.last
      expect(template.key).to eq('one_week_heads_up')
      expect(template.category).to eq('scheduling')
      expect(template.subject).to eq('See you soon')
      expect(template.organization).to eq(organization)
      expect(response).to have_http_status(:ok)
    end

    it 'creates a followup template when category=followup is supplied' do
      post :create, params: base_params.deep_merge(email_template: { category: 'followup', title: 'Second Attempt' })

      expect(response).to have_http_status(:ok)
      template = EmailTemplate.last
      expect(template.category).to eq('followup')
      expect(template.key).to eq('second_attempt')
    end

    it 'creates a template in every workflow category' do
      EmailTemplate::CATEGORIES.each_with_index do |category, index|
        post :create, params: base_params.deep_merge(
          email_template: { category: category, title: "Template #{index}" }
        )

        expect(response).to have_http_status(:ok), "expected #{category} to be creatable"
        expect(EmailTemplate.last.category).to eq(category)
      end
    end

    it 'rejects the retired default category' do
      expect {
        post :create, params: base_params.deep_merge(email_template: { category: 'default' })
      }.not_to change(EmailTemplate, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'rejects creating a template with no category' do
      params = base_params.deep_dup
      params[:email_template].delete(:category)

      expect {
        post :create, params: params
      }.not_to change(EmailTemplate, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 422 when the title is blank' do
      post :create, params: base_params.deep_merge(email_template: { title: '   ' })
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 422 when the slug collides with an existing template in the same org' do
      organization.email_templates.create!(
        key: 'one_week_heads_up',
        subject: 'x',
        content: 'y',
        category: 'scheduling'
      )

      expect {
        post :create, params: base_params
      }.not_to change(EmailTemplate, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE #destroy' do
    let!(:scheduling_template) do
      organization.email_templates.create!(
        key: 'one_week_heads_up',
        subject: 'See you soon',
        content: 'Hi',
        category: 'scheduling'
      )
    end

    let!(:followup_template) do
      organization.email_templates.create!(
        key: 'second_attempt',
        subject: 'Following up again',
        content: 'Hi',
        category: 'followup'
      )
    end

    let!(:seeded_template) do
      organization.email_templates.create!(
        key: 'quote_mailout',
        subject: 'Quote',
        content: 'Body',
        category: 'quote'
      )
    end

    let!(:seeded_followup_template) do
      organization.email_templates.create!(
        key: 'no_response',
        subject: 'Following up',
        content: 'Body',
        category: 'followup'
      )
    end

    it 'deletes a scheduling template' do
      expect {
        delete :destroy, params: { id: scheduling_template.key, format: :json }
      }.to change(EmailTemplate, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'deletes a followup template' do
      expect {
        delete :destroy, params: { id: followup_template.key, format: :json }
      }.to change(EmailTemplate, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'refuses to delete a template the workflow sends by key' do
      expect {
        delete :destroy, params: { id: seeded_template.key, format: :json }
      }.not_to change(EmailTemplate, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'refuses to delete a seeded template even in a user-managed category' do
      expect {
        delete :destroy, params: { id: seeded_followup_template.key, format: :json }
      }.not_to change(EmailTemplate, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'does not allow deleting a template from another organization' do
      other_org = create(:organization)
      other_template = other_org.email_templates.create!(
        key: 'other_template',
        subject: 'x',
        content: 'y',
        category: 'scheduling'
      )

      expect {
        delete :destroy, params: { id: other_template.key, format: :json }
      }.not_to change(EmailTemplate, :count)

      expect(response).to have_http_status(:not_found)
    end
  end
end
