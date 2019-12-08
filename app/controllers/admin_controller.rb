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

	def update_costs
		@estimate = Estimate.find(params[:id])
	end

	def edit_extra_costs
		@estimate = Estimate.find(params[:id])
	end

	def set_work_date
		@estimate = Estimate.find(params[:id])
	end

	def update_estimate
		@estimate = Estimate.find(params[:estimate_id])
		@estimate.update(estimate_params)

		redirect_to estimate_path(@estimate)
	end

	def submit_updated_costs
		@estimate = Estimate.find(params[:estimate_id])

		params[:trees].each do |tree|
			db_tree = Tree.find(tree[:id])
			db_tree.update(cost: tree[:cost], notes: tree[:notes])
		end

		@estimate.save!

		if(params[:commit] == 'Update and Add Extras')
			redirect_to "/admin/edit_extra_costs?id=#{@estimate.id}"
		else
			redirect_to estimate_path(@estimate)
		end
	end

	def update_start_date
		@date_field = SiteConfig.where(attribute_name: "start_date").first
		if !params[:start_date].nil?
			@date_field.attribute_value = params[:start_date]
			@date_field.save
			@change_status = "Successfully Changed"
		else
			@change_status = "Could Not Change"
		end
		@current_start_date = SiteConfig.where(attribute_name: "start_date").first.attribute_value

		redirect_to controller: 'admin', action: 'admin_panel'
	end

private

	def estimate_params
		params.require(:estimate).permit(
			:status, :work_date, :extra_cost, :extra_cost_notes, :is_unknown
		)
	end
end
