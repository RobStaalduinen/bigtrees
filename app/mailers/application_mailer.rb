class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@bigtrees.ca"
  layout 'mailer'
  def send_direct_mail(to:, subject:, body:, organization:, attachment: nil, outgoing_name: '', bcc: [])
    if Rails.env.development?
      to = 'rob.staalduinen@gmail.com'
      subject = "[TEST EMAIL] #{subject}"
    end

    email_definition = Nylas::EmailDefinition.new(
      to: to,
      subject: subject,
      outgoing_name: outgoing_name,
      body: body,
      bcc: bcc.compact
    )

    Nylas::Wrapper.new.send_email(organization.nylas_account, email_definition, attachment)
  end

end
