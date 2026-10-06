require 'rails_helper'

RSpec.describe NylasAccountsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:arborist) { create(:arborist, :admin, organization: organization) }

  before do
    request.cookies[:session_token] = arborist.session_token
    request.headers['X-ORGANIZATION-ID'] = organization.id.to_s
  end

  describe 'GET #receive_grant' do
    let(:token_response) do
      { grant_id: 'grant-xyz', email: 'owner@example.com' }
    end

    it 'exchanges the code and records the grant' do
      wrapper = instance_double(Nylas::Wrapper)
      expect(Nylas::Wrapper).to receive(:new).and_return(wrapper)
      allow(wrapper).to receive(:exchange_code_for_token).with('the-code').and_return(token_response)

      get :receive_grant, params: { code: 'the-code', state: organization.id.to_s }

      account = organization.reload.nylas_account
      expect(account.grant_id).to eq('grant-xyz')
      expect(account.outgoing_email_address).to eq('owner@example.com')
      expect(account.status).to eq('active')
      expect(response).to redirect_to('/admin/company?section=outgoing_email')
    end

    context 'when the provider leg failed' do
      it 'persists nothing and redirects with the provider error' do
        expect(Nylas::Wrapper).not_to receive(:new)

        get :receive_grant, params: {
          state: organization.id.to_s,
          error: 'provider_code_request_failed',
          error_description: 'Provider refused to return refresh_token using code'
        }

        expect(organization.reload.nylas_account).to be_nil
        expect(response.location).to include('email_error=Provider+refused')
      end
    end

    context 'when the exchange returns no grant' do
      it 'persists nothing' do
        wrapper = instance_double(Nylas::Wrapper)
        allow(Nylas::Wrapper).to receive(:new).and_return(wrapper)
        allow(wrapper).to receive(:exchange_code_for_token).and_return({ email: 'owner@example.com' })

        get :receive_grant, params: { code: 'the-code', state: organization.id.to_s }

        expect(organization.reload.nylas_account).to be_nil
        expect(response.location).to include('email_error=')
      end
    end
  end
end
