module CustomerEmailRecordable
  extend ActiveSupport::Concern

  private

  def record_customer_email(estimate:, template_key:, nylas_response:, recipient_email: nil)
    return if template_key.blank?
    return if nylas_response.nil?

    EmailRecord.create!(
      estimate: estimate,
      arborist: current_user,
      organization: estimate.organization,
      template_key: template_key,
      recipient_email: Array(recipient_email).first,
      nylas_message_id: Nylas::Wrapper.extract_message_id(nylas_response),
      sent_at: Time.current
    )
  end
end
