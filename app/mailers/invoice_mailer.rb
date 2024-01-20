class InvoiceMailer < ApplicationMailer
	default from: 'Tyler, Big Tree Services <tbrewer@bigislandgroup.ca>'
	add_template_helper(ApplicationHelper)
	include Rails.application.routes.url_helpers
	include ActionView::Helpers::UrlHelper

	def receipt(estimate, email, subject, content)
		invoice = estimate.invoice
		@content = content
		file = invoice.pdf_receipt
		attachments[invoice.pdf_receipt_fle_name] = File.read(file)
		mail(to: email, from: estimate.organization.quote_author, subject: subject, bcc: ['rob.staalduinen@gmail.com', estimate.organization.quote_bcc])
  end
end
