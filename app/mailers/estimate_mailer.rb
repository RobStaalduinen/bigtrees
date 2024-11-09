class EstimateMailer < ApplicationMailer
 #default from: 'Big Tree Care <no-reply@bigtreeservices.ca>'
 default from: 'Big Tree Care <no-reply@bigtreeservices.ca>'

	add_template_helper(ApplicationHelper)
	 include Rails.application.routes.url_helpers
	include ActionView::Helpers::UrlHelper

	def estimate_alert(estimate_id)
		@estimate = Estimate.find_by_id(estimate_id)
    @organization = @estimate.organization

    subject = "#{@organization.name} - BigTree Estimate Request from " + @estimate.customer.name

		if Rails.env.production?
			mail(to: @organization.email, bcc: 'rob.staalduinen@gmail.com', subject: subject)
		else
			mail(to: 'rob.staalduinen@gmail.com', subject: subject)
		end
	end

  def commercial_quote_request(organization, contact_params)
    @organization = organization
    @contact_params = contact_params

    subject = "#{@organization.name} - Commercial Quote Request from " + contact_params[:name]

    if Rails.env.production?
			mail(to: @organization.email, bcc: 'rob.staalduinen@gmail.com', subject: subject)
		else
			mail(to: 'rob.staalduinen@gmail.com', subject: subject)
		end
  end

	def test_email(recipient)

		mail(to: 'rob.staalduinen@gmail.com', subject: "Test - #{Date.today.strftime("%D-%M")}")
	end
end
