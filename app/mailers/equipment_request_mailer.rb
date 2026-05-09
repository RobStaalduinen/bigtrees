class EquipmentRequestMailer < ApplicationMailer
	default from: 'Tyler, Big Tree Services <tbrewer@bigislandgroup.ca>'

	helper ApplicationHelper
	include Rails.application.routes.url_helpers
	include ActionView::Helpers::UrlHelper

  def new_request_alert(equipment_request)
    @organization = equipment_request.organization
    return unless @organization.notification_enabled?(:equipment_repair)
    return unless @organization.nylas_account

    @equipment_request = equipment_request

    subject = "New Equipment Repair/Maintenance Request - #{equipment_request.category.humanize}"

    content = render_to_string(template: 'equipment_request_mailer/new_request_alert', formats: [:html])

    send_direct_mail(
      to: @organization.email,
      subject: subject,
      body: content,
      organization: @organization,
      bcc: ['rob.staalduinen@gmail.com']
    )
  end

  def request_email(equipment_request, email, subject, content)
    @equipment_request = equipment_request
    @content = content

    file_path = "tmp/equipment-request-#{equipment_request.id}.png"

    if equipment_request.image_path
      open(file_path, 'wb') do |file|
        file << open(equipment_request.image_url).read
      end

      attachments["equipment-request-#{equipment_request.id}.png"] = File.read(file_path)
    end

		mail(to: email, subject: subject, bcc: ['rob.staalduinen@gmail.com'])
  end
end
