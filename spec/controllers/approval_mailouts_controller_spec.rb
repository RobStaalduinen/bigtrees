require 'rails_helper'

RSpec.describe ApprovalMailoutsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:arborist) { create(:arborist, :admin, organization: organization) }
  let(:customer) { create(:customer) }
  let(:estimate) { create(:estimate, :complete, organization: organization, arborist: arborist, customer: customer) }

  let(:valid_params) do
    {
      estimate_id: estimate.id,
      dest_email: 'customer@example.com',
      subject: 'Your Tree Job',
      content: 'Hi there, your job is scheduled.',
      format: :json
    }
  end

  before do
    request.cookies[:session_token] = arborist.session_token
    request.headers['X-ORGANIZATION-ID'] = organization.id.to_s
  end

  def sign_out
    request.cookies[:session_token] = nil
  end

  describe 'POST #create' do
    before do
      allow_any_instance_of(QuoteMailer).to receive(:quote_email).and_return(double('nylas_response'))
      allow(Nylas::Wrapper).to receive(:extract_message_id).and_return('nylas-msg-123')
    end

    context 'when authenticated' do
      it 'returns 200' do
        post :create, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'calls QuoteMailer#quote_email with the request params and include_quote: false' do
        expect_any_instance_of(QuoteMailer).to receive(:quote_email).with(
          estimate,
          'customer@example.com',
          'Your Tree Job',
          'Hi there, your job is scheduled.',
          false
        ).and_return(double('nylas_response'))

        post :create, params: valid_params
      end

      it 'creates one EmailRecord with template_key approval_mailout' do
        expect {
          post :create, params: valid_params
        }.to change(EmailRecord, :count).by(1)

        record = EmailRecord.last
        expect(record.template_key).to eq('approval_mailout')
      end

      it 'sets the correct attributes on the EmailRecord' do
        post :create, params: valid_params
        record = EmailRecord.last
        expect(record.arborist).to eq(arborist)
        expect(record.organization).to eq(organization)
        expect(record.recipient_email).to eq('customer@example.com')
        expect(record.sent_at).to be_within(5.seconds).of(Time.current)
      end
    end

    context 'when unauthenticated' do
      before { sign_out }

      it 'is redirected or unauthorized' do
        post :create, params: valid_params
        expect(response).to have_http_status(:redirect).or have_http_status(:unauthorized)
      end
    end

    context 'when estimate belongs to a different organization' do
      let(:other_org) { create(:organization) }
      let(:other_arborist) { create(:arborist, :admin, organization: other_org) }
      let(:other_estimate) { create(:estimate, :complete, organization: other_org, arborist: other_arborist, customer: create(:customer)) }

      it 'returns an error (policy scope excludes the estimate)' do
        post :create, params: valid_params.merge(estimate_id: other_estimate.id)
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
