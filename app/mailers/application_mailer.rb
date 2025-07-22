class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@bigtrees.ca"
  layout 'mailer'

  def send_direct_mail(to:, subject:, body:, organization:)
    if Rails.env.development?
      to = 'rob.staalduinen@gmail.com'
    end
    
    email_definition = Nylas::EmailDefinition.new(
      to: to,
      subject: subject,
      outgoing_name: '',
      body: body,
      bcc: ['rob.staalduinen@gmail.com']
    )
    Nylas::Wrapper.new.send_email(organization.nylas_account, email_definition)
  end
  
end
