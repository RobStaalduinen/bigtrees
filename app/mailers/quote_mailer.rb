class QuoteMailer < ApplicationMailer
	default from: 'Tyler, Big Tree Services <tbrewer@bigislandgroup.ca>'

	add_template_helper(ApplicationHelper)
	include Rails.application.routes.url_helpers
	include ActionView::Helpers::UrlHelper

	def quote_email(estimate, email, subject, content, include_quote = true)
		@content = content
		@organization = estimate.organization
		return unless @organization.nylas_account

		file = include_quote ? estimate.pdf_quote : nil
		attachment = include_quote ? Nylas::Attachment.new(name: estimate.pdf_file_name, file_path: file) : nil
		content = render_to_string(template: "quote_mailer/quote_email", formats: [:html])

		send_direct_mail(
			to: email,
			subject: subject,
			body: content,
			organization: @organization,
			attachment: attachment,
			bcc: ['rob.staalduinen@gmail.com', estimate.organization.quote_bcc]
		)
	end
end
