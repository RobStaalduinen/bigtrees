class DeviseMailer < Devise::Mailer

  def reset_password_instructions(record, token, opts = {})
    @token = token
    @resource = record

    organization = record.organizations
                         .includes(:nylas_account)
                         .find { |org| org.nylas_account&.active? }

    if organization && send_nylas_mail?
      subject = 'Reset your Big Tree Admin password'
      content = render_to_string(
        template: 'devise/mailer/reset_password_instructions',
        formats: [:html]
      )

      send_direct_mail(
        to: record.email,
        subject: subject,
        body: content,
        organization: organization,
        outgoing_name: 'System - Big Tree Admin'
      )
    else
      super
    end
  end

end
