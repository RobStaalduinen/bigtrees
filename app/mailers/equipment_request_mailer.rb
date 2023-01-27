class EquipmentRequestMailer < ApplicationMailer
	default from: 'Tyler, Big Tree Services <tbrewer@bigislandgroup.ca>'

	add_template_helper(ApplicationHelper)
	include Rails.application.routes.url_helpers
	include ActionView::Helpers::UrlHelper

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
