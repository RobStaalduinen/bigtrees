class InvoiceMailer < ApplicationMailer
	default from: 'Tyler, Big Tree Services <tbrewer@bigislandgroup.ca>'
	add_template_helper(ApplicationHelper)
	include Rails.application.routes.url_helpers
	include ActionView::Helpers::UrlHelper

	def receipt(estimate, email, subject, content)
		invoice = estimate.invoice
		@content = content
		@organization = estimate.organization
		file = invoice.pdf_receipt
		
		if @organization.nylas_account && send_nylas_mail? && @organization.feature_enabled?(:receipt_alternate_send)
			
			attachment = Nylas::Attachment.new(name: invoice.pdf_receipt_file_name, file_path: file)
			content = render_to_string(template: "invoice_mailer/receipt", formats: [:html])

      send_direct_mail(
        to: email, 
        subject: subject, 
        body: content, 
        organization: @organization,
				attachment: attachment,
        bcc: ['rob.staalduinen@gmail.com', estimate.organization.quote_bcc]
      )
		else
			attachments[invoice.pdf_receipt_file_name] = File.read(file)
			mail(to: email, from: estimate.organization.quote_author, subject: subject, bcc: ['rob.staalduinen@gmail.com', estimate.organization.quote_bcc])
		end
	end
end
