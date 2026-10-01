require 'rails_helper'

RSpec.describe QuoteSettingsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:arborist) { create(:arborist, :admin, organization: organization) }

  before do
    request.cookies[:session_token] = arborist.session_token
    request.headers['X-ORGANIZATION-ID'] = organization.id.to_s
  end

  describe 'GET #show' do
    it 'reports everything on when no record exists, without creating one' do
      expect {
        get :show, params: { organization_id: organization.id, format: :json }
      }.not_to change(QuoteSetting, :count)

      payload = JSON.parse(response.body)['quote_setting']
      expect(payload['include_image_page']).to be(true)
      expect(payload['include_pre_job_page']).to be(true)
      expect(payload['include_terms']).to be(true)
    end

    it 'reports the stored values once a record exists' do
      QuoteSetting.create!(organization: organization, include_terms: false)

      get :show, params: { organization_id: organization.id, format: :json }

      payload = JSON.parse(response.body)['quote_setting']
      expect(payload['include_terms']).to be(false)
      expect(payload['include_image_page']).to be(true)
    end
  end

  describe 'PUT #update' do
    it 'creates the record on first change' do
      expect {
        put :update, params: {
          organization_id: organization.id,
          quote_settings: { include_image_page: false },
          format: :json
        }
      }.to change(QuoteSetting, :count).by(1)

      expect(organization.reload.quote_settings.include_image_page).to be(false)
    end

    it 'updates in place rather than adding a second record' do
      QuoteSetting.create!(organization: organization)

      expect {
        put :update, params: {
          organization_id: organization.id,
          quote_settings: { include_terms: false },
          format: :json
        }
      }.not_to change(QuoteSetting, :count)

      expect(organization.reload.quote_settings.include_terms).to be(false)
    end

    it 'does not touch another organization’s settings' do
      other = create(:organization)

      expect {
        put :update, params: {
          organization_id: other.id,
          quote_settings: { include_terms: false },
          format: :json
        }
      }.not_to change(QuoteSetting, :count)

      expect(response).not_to have_http_status(:ok)
      expect(other.reload.quote_settings).to be_nil
    end
  end
end
