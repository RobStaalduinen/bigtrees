class AdminController < ApplicationController
	include UserHelper
	require 'spreadsheet'
	Spreadsheet.client_encoding = 'UTF-8'

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

def admin_panel
	@estimates = Estimate.submitted.order('id DESC')
	@receipt_number = current_user.receipts.count
	# @current_start_date = SiteConfig.where(attribute_name: "start_date").first.attribute_value
end

def view_estimate
	@estimate = Estimate.find(params[:id])
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
	# @estimate.set_status

	redirect_to admin_estimates_path(id: @estimate.id)
end

def submit_updated_costs
	@estimate = Estimate.find(params[:estimate_id])

	params[:trees].each do |tree|
		db_tree = Tree.find(tree[:id])
		db_tree.update(cost: tree[:cost], notes: tree[:notes])
	end

	# @estimate.set_status

	if(params[:commit] == 'Update and Add Extras')
		redirect_to "/admin/edit_extra_costs?id=#{@estimate.id}"
	else
		redirect_to admin_estimates_path(id: @estimate.id)
	end
end






def view_all_appointments_and_estimates
	@appointments = Appointment.where(status: "COMPLETE").order("id DESC")
	@estimates = Estimate.where(status: "COMPLETE").order("id DESC")
end

def view_estimate_by_id
	@estimate = Estimate.find_by_id(params[:estimate_id])
	@estimate_work = WorkAction.where("estimate_id = ?", params[:estimate_id]).order(tree_index: :asc)

	image_ids = TreeImage.where(estimate_id: @estimate.id)
	@images_attached = true
	if image_ids.length == 0
		@images_attached = false
	end

	if @images_attached
		@tree_image_array = Array.new
		for i in 1 .. @estimate.tree_quantity.to_i
			current_tree_array = Array.new
			image_ids.each do |img|
				if img.tree_number == i
					current_tree_array.push(img)
				end
			end
			@tree_image_array.push(current_tree_array)
		end
	end
end

def get_appointment_image
  @image_data = TreeImage.find_by_id(params[:id])
  @image = @image_data.binary_data
  send_data @image, :type     => @image_data.content_type, :filename => @image_data.filename, :disposition => 'inline'
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
