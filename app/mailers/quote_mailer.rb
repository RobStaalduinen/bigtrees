class QuoteMailer < ApplicationMailer
	default from: 'Big Tree Services <tbrewer@bigislandgroup.ca>'

	add_template_helper(ApplicationHelper)
	include Rails.application.routes.url_helpers
	include ActionView::Helpers::UrlHelper

	def quote_email(estimate, email, subject, content)
		@content = content
		file = estimate.pdf_quote
		attachments[estimate.pdf_file_name] = File.read(file)
		# mail(to: email, subject: subject, bcc: ['rob.staalduinen@gmail.com'])
		mail(to: email, subject: subject)
	end
	
	def picture_request(estimate, email, subject, content)
		estimate.update(picture_request_sent_at: Date.today)
		@content = content
		mail(to: email, subject: subject, bcc: ['rob.staalduinen@gmail.com', 'tbrewer@bigislandgroup.ca'])
	end
end
