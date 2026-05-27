require 'rails_helper'

RSpec.describe EmailRecordsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:arborist) { create(:arborist, :admin, organization: organization) }
  let(:customer) { create(:customer) }
  let(:estimate) { create(:estimate, :complete, organization: organization, arborist: arborist, customer: customer) }

  before do
    request.cookies[:session_token] = arborist.session_token
    request.headers['X-ORGANIZATION-ID'] = organization.id.to_s
  end

  describe 'GET #index' do
    let!(:older_record) do
      EmailRecord.create!(
        estimate: estimate,
        arborist: arborist,
        organization: organization,
        template_key: 'quote_mailout',
        recipient_email: 'customer@example.com',
        sent_at: 3.days.ago
      )
    end

    let!(:newer_record) do
      EmailRecord.create!(
        estimate: estimate,
        arborist: arborist,
        organization: organization,
        template_key: 'no_response',
        recipient_email: 'customer@example.com',
        sent_at: 1.day.ago
      )
    end

    it 'returns records for this estimate, newest first' do
      get :index, params: { estimate_id: estimate.id, format: :json }

      expect(response).to have_http_status(:ok)
      keys = JSON.parse(response.body)['email_records'].map { |r| r['template_key'] }
      expect(keys).to eq(['no_response', 'quote_mailout'])
    end

    it 'does not include records for other estimates' do
      other_estimate = create(:estimate, :complete, organization: organization, arborist: arborist, customer: create(:customer))
      EmailRecord.create!(
        estimate: other_estimate,
        arborist: arborist,
        organization: organization,
        template_key: 'image_request',
        sent_at: Time.current
      )

      get :index, params: { estimate_id: estimate.id, format: :json }
      keys = JSON.parse(response.body)['email_records'].map { |r| r['template_key'] }
      expect(keys).not_to include('image_request')
    end

    it "returns 500 when accessing another organization's estimate (policy scope excludes it)" do
      other_org = create(:organization)
      other_arborist = create(:arborist, :admin, organization: other_org)
      other_estimate = create(:estimate, :complete, organization: other_org, arborist: other_arborist, customer: create(:customer))

      get :index, params: { estimate_id: other_estimate.id, format: :json }
      expect(response).to have_http_status(:internal_server_error)
    end
  end
end
