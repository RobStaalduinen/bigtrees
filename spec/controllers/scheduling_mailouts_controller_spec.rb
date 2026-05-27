require 'rails_helper'

RSpec.describe SchedulingMailoutsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:arborist) { create(:arborist, :admin, organization: organization) }
  let(:customer) { create(:customer) }
  let(:estimate) { create(:estimate, :complete, organization: organization, arborist: arborist, customer: customer) }

  let!(:scheduling_template_48h) do
    organization.email_templates.create!(
      key: '48_hour_notice',
      subject: 'Your [ORGANIZATION_NAME] Job',
      content: 'Heads up — 48 hours.',
      category: 'scheduling'
    )
  end

  let!(:scheduling_template_crew) do
    organization.email_templates.create!(
      key: 'crew_on_the_way',
      subject: 'Your [ORGANIZATION_NAME] Job',
      content: 'Crew is on the way.',
      category: 'scheduling'
    )
  end

  let!(:default_template) do
    organization.email_templates.create!(
      key: 'quote_mailout',
      subject: 'Quote',
      content: 'Quote body',
      category: 'default'
    )
  end

  let(:valid_params) do
    {
      estimate_id: estimate.id,
      template_key: '48_hour_notice',
      dest_email: 'customer@example.com',
      subject: 'Your Tree Job',
      content: 'Hi there, your job is scheduled within 48h.',
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

    context 'with the 48_hour_notice template' do
      it 'returns 200' do
        post :create, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'calls QuoteMailer#quote_email with the request params and include_quote: false' do
        expect_any_instance_of(QuoteMailer).to receive(:quote_email).with(
          estimate,
          'customer@example.com',
          'Your Tree Job',
          'Hi there, your job is scheduled within 48h.',
          false
        ).and_return(double('nylas_response'))

        post :create, params: valid_params
      end

      it 'creates one EmailRecord with template_key 48_hour_notice' do
        expect {
          post :create, params: valid_params
        }.to change(EmailRecord, :count).by(1)

        record = EmailRecord.last
        expect(record.template_key).to eq('48_hour_notice')
        expect(record.arborist).to eq(arborist)
        expect(record.organization).to eq(organization)
        expect(record.recipient_email).to eq('customer@example.com')
        expect(record.sent_at).to be_within(5.seconds).of(Time.current)
      end
    end

    context 'with the crew_on_the_way template' do
      it 'creates an EmailRecord with template_key crew_on_the_way' do
        expect {
          post :create, params: valid_params.merge(template_key: 'crew_on_the_way')
        }.to change(EmailRecord, :count).by(1)

        expect(EmailRecord.last.template_key).to eq('crew_on_the_way')
      end
    end

    context 'with a default-category template key' do
      it 'rejects with 422 and does not send or record' do
        expect_any_instance_of(QuoteMailer).not_to receive(:quote_email)
        expect {
          post :create, params: valid_params.merge(template_key: 'quote_mailout')
        }.not_to change(EmailRecord, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with an unknown template key' do
      it 'rejects with 422 and does not send or record' do
        expect_any_instance_of(QuoteMailer).not_to receive(:quote_email)
        expect {
          post :create, params: valid_params.merge(template_key: 'nonexistent_template')
        }.not_to change(EmailRecord, :count)

        expect(response).to have_http_status(:unprocessable_entity)
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
