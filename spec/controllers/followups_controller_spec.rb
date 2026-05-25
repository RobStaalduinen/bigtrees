require 'rails_helper'

RSpec.describe FollowupsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:arborist) { create(:arborist, :admin, organization: organization) }
  let(:customer) { create(:customer) }
  let(:estimate) { create(:estimate, :complete, organization: organization, arborist: arborist, customer: customer) }

  let!(:no_response_template) do
    organization.email_templates.create!(
      key: 'no_response',
      subject: 'Following up',
      content: 'Hi',
      category: 'followup'
    )
  end

  let!(:image_request_template) do
    organization.email_templates.create!(
      key: 'image_request',
      subject: 'Send pictures',
      content: 'Hi',
      category: 'followup'
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
      template_key: 'no_response',
      dest_email: 'customer@example.com',
      subject: 'Following up',
      content: 'Hi there',
      include_quote: true,
      format: :json
    }
  end

  before do
    request.cookies[:session_token] = arborist.session_token
    request.headers['X-ORGANIZATION-ID'] = organization.id.to_s

    allow_any_instance_of(QuoteMailer).to receive(:quote_email).and_return(double('nylas_response'))
    allow(Nylas::Wrapper).to receive(:extract_message_id).and_return('nylas-msg-123')
  end

  describe 'POST #create' do
    context 'with the no_response template' do
      it 'sends the email with include_quote=true and updates followup_sent_at' do
        expect_any_instance_of(QuoteMailer).to receive(:quote_email).with(
          estimate,
          'customer@example.com',
          'Following up',
          'Hi there',
          true
        ).and_return(double('nylas_response'))

        post :create, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(estimate.reload.followup_sent_at).to be_within(5.seconds).of(Time.current)
        expect(estimate.picture_request_sent_at).to be_nil
      end

      it 'creates an EmailRecord' do
        expect {
          post :create, params: valid_params
        }.to change(EmailRecord, :count).by(1)

        record = EmailRecord.last
        expect(record.template_key).to eq('no_response')
        expect(record.estimate).to eq(estimate)
      end
    end

    context 'with the image_request template' do
      it 'updates picture_request_sent_at instead of followup_sent_at' do
        post :create, params: valid_params.merge(template_key: 'image_request', include_quote: false)

        expect(response).to have_http_status(:ok)
        expect(estimate.reload.picture_request_sent_at).to eq(Date.current)
        expect(estimate.followup_sent_at).to be_nil
      end

      it 'passes include_quote=false when the param is false' do
        expect_any_instance_of(QuoteMailer).to receive(:quote_email).with(
          estimate,
          anything, anything, anything,
          false
        ).and_return(double('nylas_response'))

        post :create, params: valid_params.merge(template_key: 'image_request', include_quote: false)
      end
    end

    context 'with a default-category template key' do
      it 'rejects with 422 and does not send or record' do
        expect_any_instance_of(QuoteMailer).not_to receive(:quote_email)
        expect {
          post :create, params: valid_params.merge(template_key: 'quote_mailout')
        }.not_to change(EmailRecord, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(estimate.reload.followup_sent_at).to be_nil
      end
    end

    context 'with an unknown template key' do
      it 'rejects with 422' do
        expect {
          post :create, params: valid_params.merge(template_key: 'nonexistent')
        }.not_to change(EmailRecord, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with a custom followup template' do
      let!(:custom_template) do
        organization.email_templates.create!(
          key: 'second_attempt',
          subject: 'Just checking in',
          content: 'Hi',
          category: 'followup'
        )
      end

      it 'sends and falls back to followup_sent_at' do
        post :create, params: valid_params.merge(template_key: 'second_attempt', include_quote: false)

        expect(response).to have_http_status(:ok)
        expect(estimate.reload.followup_sent_at).to be_within(5.seconds).of(Time.current)
        expect(estimate.picture_request_sent_at).to be_nil
      end
    end
  end
end
