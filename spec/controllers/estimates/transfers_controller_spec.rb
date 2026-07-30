require 'rails_helper'

RSpec.describe Estimates::TransfersController, type: :controller do
  let(:organization) { create(:organization, :can_transfer) }
  let(:arborist)     { create(:arborist, :admin, organization: organization) }
  let(:customer)     { create(:customer) }

  let(:target_org) { create(:organization) }
  let!(:target_arborist) { create(:arborist, :admin, organization: target_org) }

  let!(:estimate) do
    create(:estimate, :complete, organization: organization, arborist: arborist, customer: customer)
  end

  before do
    request.cookies[:session_token] = arborist.session_token
    request.headers['X-ORGANIZATION-ID'] = organization.id.to_s
  end

  def sign_out
    request.cookies[:session_token] = nil
  end

  describe 'POST #create' do
    it 'transfers the quote and returns the new estimate id' do
      expect {
        post :create, params: { estimate_id: estimate.id, target_organization_id: target_org.id }, format: :json
      }.to change(Estimate, :count).by(1)

      body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(body['estimate_id']).to be_present
      expect(Estimate.find(body['estimate_id']).organization).to eq(target_org)
      expect(estimate.reload.state).to eq('transferred')
    end

    context 'when the source org may not transfer' do
      let(:organization) { create(:organization) } # can_transfer defaults to false

      it 'returns 422 and does not create a copy' do
        expect {
          post :create, params: { estimate_id: estimate.id, target_organization_id: target_org.id }, format: :json
        }.not_to change(Estimate, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to be_present
      end
    end

    context 'when the source estimate belongs to a different organization' do
      let(:other_org)      { create(:organization) }
      let(:other_arborist) { create(:arborist, :admin, organization: other_org) }
      let(:other_estimate) do
        create(:estimate, :complete, organization: other_org, arborist: other_arborist, customer: customer)
      end

      it 'returns an error (Pundit scope excludes it)' do
        post :create, params: { estimate_id: other_estimate.id, target_organization_id: target_org.id }, format: :json
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context 'when not signed in' do
      before { sign_out }

      it 'redirects to login' do
        post :create, params: { estimate_id: estimate.id, target_organization_id: target_org.id }
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
