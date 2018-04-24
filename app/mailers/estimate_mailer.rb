class EstimateMailer < ApplicationMailer
	default from: 'Big Tree Care <no-reply@bigtreeservices.com>'
	add_template_helper(ApplicationHelper)
	 include Rails.application.routes.url_helpers
	include ActionView::Helpers::UrlHelper

	def estimate_email(estimate_id, email)
		@current_estimate = Estimate.find_by_id(estimate_id)
		@estimate_work = WorkAction.where("estimate_id = ? AND status = ?", estimate_id, "COMPLETE").order(tree_index: :asc)

		mail(to: email, subject: "Your Estimate from BigTree.ca - " + @current_estimate.estimate_number)
	end

	def appointment_alert(appointment_id)
		@current_appointment = Appointment.find_by_id(appointment_id)

		mail(to: 'rob.staalduinen@gmail.com', subject: "BigTree Appointment Request from " + @current_appointment.name)
	end

	def estimate_alert(estimate_id)
		@estimate = Estimate.find_by_id(estimate_id)

		if Rails.env.production?
			mail(to: 'Tbrewer@bigislandgroup.ca', bcc: 'rob.staalduinen@gmail.com', subject: "BigTree Estimate Request from " + @estimate.name)
		else
			mail(to: 'rob.staalduinen@gmail.com', subject: "BigTree Estimate Request from " + @estimate.name)
		end
	end

	def test_email(recipient)
		mail(to: 'rob.staalduinen@gmail.com', subject: "Test")
	end
end
