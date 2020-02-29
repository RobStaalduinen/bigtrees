class AdminController < ApplicationController
	require 'spreadsheet'
	Spreadsheet.client_encoding = 'UTF-8'

	layout 'admin'

	before_action :signed_in_user, except: [:log_in]

	def log_in
		if !params[:commit].nil? and params[:commit].eql?"Log In"
			user = Arborist.where("email LIKE ?", params[:username]).first
				if !user.nil? && params[:password] == user.password
					logger.debug "Sign In"
					sign_in(user)
					logger.debug current_user
					redirect_to url_for(:controller => 'admin', :action => 'admin_panel')
				else
					flash.now[:warning] = "Invalid Username/Password"
				end
		end
	end

	def update_estimate
		@estimate = Estimate.find(params[:estimate_id])
		@estimate.update(estimate_params)

		redirect_to estimate_path(@estimate)
	end

private

	def estimate_params
		params.require(:estimate).permit(
			:status, :work_date, :extra_cost, :extra_cost_notes, :is_unknown
		)
	end
end
