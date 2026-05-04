class EstimateMailer < ApplicationMailer
 #default from: 'Big Tree Care <no-reply@bigtreeservices.ca>'
 default from: 'Big Tree Care <no-reply@bigtreeservices.ca>'

	add_template_helper(ApplicationHelper)
	 include Rails.application.routes.url_helpers
	include ActionView::Helpers::UrlHelper

	def estimate_alert(estimate_id)
		@estimate = Estimate.find_by_id(estimate_id)
    @organization = @estimate.organization
    return unless @organization.nylas_account

    subject = "#{@organization.name} - BigTree Estimate Request from " + @estimate.customer.name
		content = render_to_string(template: "estimate_mailer/estimate_alert", formats: [:html])
		send_direct_mail(
      to: @organization.email,
      subject: subject,
      body: content,
      organization: @organization
    )
	end

  def commercial_quote_request(organization, contact_params)
    @organization = organization
    @contact_params = contact_params
    return unless @organization.nylas_account

    subject = "#{@organization.name} - Commercial Quote Request from " + contact_params[:name]
		content = render_to_string(template: "estimate_mailer/commercial_quote_request", formats: [:html])
		send_direct_mail(
			to: @organization.email,
			subject: subject,
			body: content,
			organization: @organization
		)
  end

	def test_email(recipient)

		mail(to: 'rob.staalduinen@gmail.com', subject: "Test - #{Date.today.strftime("%D-%M")}")
	end
end
