class QuoteMailer < ApplicationMailer
	default from: 'Tyler, Big Tree Services <tbrewer@bigislandgroup.ca>'

	add_template_helper(ApplicationHelper)
	include Rails.application.routes.url_helpers
	include ActionView::Helpers::UrlHelper

	def quote_email(estimate, email, subject, content, include_quote = true)
		@content = content

		if include_quote
			file = estimate.pdf_quote
			attachments[estimate.pdf_file_name] = File.read(file)
    end

		mail(to: email, from: estimate.organization.quote_author, subject: subject, bcc: ['rob.staalduinen@gmail.com', estimate.organization.quote_bcc].compact)
	end

	def picture_request(estimate, email, subject, content)
		estimate.update(picture_request_sent_at: Date.today)
		@content = content
		mail(to: email, from: estimate.organization.quote_author, subject: subject, bcc: ['rob.staalduinen@gmail.com', estimate.organization.quote_bcc])
	end
end
