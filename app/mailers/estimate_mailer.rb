class EstimateMailer < ApplicationMailer
 #default from: 'Big Tree Care <no-reply@bigtreeservices.ca>'
 default from: 'Big Tree Care <no-reply@bigtreeservices.ca>'

	add_template_helper(ApplicationHelper)
	 include Rails.application.routes.url_helpers
	include ActionView::Helpers::UrlHelper

	def estimate_alert(estimate_id)
		@estimate = Estimate.find_by_id(estimate_id)

		if Rails.env.production?
			mail(to: 'Tbrewer@bigislandgroup.ca', bcc: 'rob.staalduinen@gmail.com', subject: "BigTree Estimate Request from " + @estimate.customer.name)
		else
			mail(to: 'rob.staalduinen@gmail.com', subject: "BigTree Estimate Request from " + @estimate.customer.name)
		end
	end

	def test_email(recipient)

		mail(to: 'rob.staalduinen@gmail.com', subject: "Test - #{Date.today.strftime("%D-%M")}")
	end
end
