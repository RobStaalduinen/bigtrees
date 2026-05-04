class ReceiptMailer < ApplicationMailer
  def new_receipt_alert(receipt)
    @organization = receipt.organization
    return unless @organization.feature_enabled?(:receipt_notifications)
    return unless @organization.nylas_account

    @receipt = receipt

    subject = "New Receipt Submitted - #{receipt.category} by #{receipt.arborist.name}"

    content = render_to_string(template: 'receipt_mailer/new_receipt_alert', formats: [:html])

    send_direct_mail(
      to: @organization.email,
      subject: subject,
      body: content,
      organization: @organization,
      bcc: ['rob.staalduinen@gmail.com']
    )
  end
end
