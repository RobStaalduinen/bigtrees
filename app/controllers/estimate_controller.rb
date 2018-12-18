class EstimateController < ApplicationController
	require 'date'
	$work_data = ["tree_work_1", "tree_work_2", "tree_work_3"]

	$one_man_labour_hour_cost = 142.61
	$two_man_labour_hour_cost = 167.88
	$supervisor_hour_cost = 25.36
	$fuel_cost = 15
	$CDN_tax_rate = 1.13
	$interac_cost = 1.02

	$trim_options = ['0-10%', '10-25%', '25-50%']

	$months = ["NULL", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

	def create

	end

	def update
		@estimate = Estimate.find(params[:id])
		@estimate.update(estimate_params)
		redirect_to admin_estimates_path(id: @estimate.id)
	end

	def new
		SiteStat.increment_estimates()
		if params[:trees].nil?
			@num_trees = 1
		else
			@num_trees = params[:trees]
		end
		logger.debug "Value of Trees is " + @num_trees.to_s
		logger.debug "New Estimate Starting"
		respond_to do |format|
			format.html {}
			format.js {}
		end
	end

	def submit_new_estimate
		@do_remote = true

		new_estimate = Estimate.new
		new_estimate.name = params[:name]
		new_estimate.address = params[:address_line_1]
		new_estimate.city = params[:city]
		new_estimate.tree_quantity = params[:num_trees]
		new_estimate.contact_type = params[:contact_type]
		new_estimate.contact_method = params[:contact_method]
		new_estimate.status = "IN PROGRESS"
		dt = Date.today
		today = dt.year.to_s + "-" + dt.month.to_s + "-" + dt.day.to_s
		new_estimate.date_submitted = today
		new_estimate.last_change = today

		new_estimate.save

		@estimate = new_estimate


		for i in 0..$work_data.length - 1
			new_work_activity = params[$work_data[i]]
			if !new_work_activity.nil?
				work = WorkAction.new

				work.estimate_id = new_estimate.id
				work.work_type = new_work_activity
				work.tree_index = (i+1)
				work.status = "IN PROGRESS"
				work.save
			end

		end
		respond_to do |format|
		  format.js
		end
	end

	def submit_tree_images
		@estimate = Estimate.find_by_id(params[:estimate_id])
		if params[:commit] != "Skip"
			@num_trees = params[:num_trees].to_i
			for i in 1..3
				for j in 1..4
					tree_string = "tree_" + i.to_s + "_image_" + j.to_s
					user_image = params[tree_string]
					if user_image.present?
						new_image = TreeImage.new(estimate_id: @estimate.id, tree_number: i)
						new_image.asset = user_image
						new_image.save
					end
				end
			end
		end
		EstimateMailer.estimate_alert(params[:estimate_id]).deliver_later
		@estimate.response = "RESPONSE REQRUIRED"
		@estimate.status = "COMPLETE"
		@estimate.save
		redirect_to :action => 'display_estimate', :estimate_id => @estimate.id
	end

	def submit_job_questions
		@estimate = Estimate.find_by_id(params[:estimate_id])

		@estimate.stump_removal = params[:stump]
		@estimate.vehicle_access = params[:vehicle]
		@estimate.breakables = params[:break]
		@estimate.wood_removal = params[:wood]
		@estimate.status = "AWAITING IMAGES"
		@estimate.save

		respond_to do |format|
		  format.js
		end
	end

	def file_tree_forms
		workArray = WorkAction.where("estimate_id = ? AND status = ?", params[:estimate_id], "IN PROGRESS").order(tree_index: :asc)
		logger.debug "LENGTH: " + (workArray.length.to_s)
		@do_remote = true
		if workArray.length == 1
			@do_remote = false
		end
		@current_work = workArray[0]
		@trim_options = $trim_options
		respond_to do |format|
		  format.js {}
		end
	end

	def submit_tree_form
		current_work = WorkAction.find_by_id(params[:work_id])

		if current_work.work_type == "Removal"
			info = params[:stump] + "|" + params[:vehicle] + "|" + params[:break] + "|" + params[:wood]
		else
			info = params[:percentage] + "|" + params[:vehicle] + "|" + params[:break] + "|" + params[:wood]
		end

		current_work.tree_stories = params[:size]
		current_work.info = info
		current_work.status = "COMPLETE"

		if current_work.work_type == "Removal"
			tree_cost = calculate_removal_costs(current_work)
		else
			tree_cost = calculate_trim_costs(current_work)
		end

		current_work.cost = tree_cost

		current_work.save
		if !params[:do_remote].nil? and params[:do_remote] == "true"
			redirect_to :action => 'file_tree_forms', :format => 'js', :estimate_id => current_work.estimate_id
		else
			redirect_to :action => 'lookup_estimate', :estimate_id => current_work.estimate_id
		end

	end

	def display_estimate
		@current_estimate = nil
		@current_estimate = Estimate.find_by_id(params[:estimate_id])

		if @current_estimate.nil?
			redirect_to :action => 'new'
		end

	end

	def change_trees
		logger.debug "Change Trees Called"
	end

	def lookup_estimate
		if !params[:estimate_id].nil?
			estimate = Estimate.find_by_id(params[:estimate_id])
			redirect_to :action => 'display_estimate', :estimate_number => estimate.estimate_number

		elsif !params[:estimate_number].nil?
			redirect_to :action => 'display_estimate', :estimate_number => params[:estimate_number]
		else
			redirect_to :action => 'new'
		end
	end

	def estimate_tooltips
		if params[:tooltip] == "Stump"
			@modal_header = "Stump Removal"
			@modal_body = "We are able to remove the tree and its roots from the ground as well.<br /><br />Whether you would like to plant a tree in the same spot, or just grow grass, we make it possible.".html_safe
		elsif params[:tooltip] == "Wood"
			@modal_header = "Wood Removal"
			@modal_body = "Once the tree is cut up and lying on the ground, some customers choose to keep the wood for firewood or lumber.<br /><br />It saves us the time to remove the wood, and we then pass the savings on to you!".html_safe
		elsif params[:tooltip] == "Vehicle"
			@modal_header = "Vehicle Access"
			@modal_body = "Is the tree near a driveway or road?<br /><br />Are we allowed to drive on the grass?<br /><br />If we are able to move our equipment beside the tree, we are able to work faster and save time and money.".html_safe
		elsif params[:tooltip] == "Breakables"
			@modal_header = "Breakables"
			@modal_body = "Breakables that cannot be moved from under the tree make the job trickier and more costly.<br /><br />Breakables we often find under a tree include but are not limited to: Powerlines, fences, decks, etc.<br /><br />Common examples of things that can be moved are tables, chairs, birdfeeders, and small statues.".html_safe
		elsif params[:tooltip] == "Size"
			@modal_header = "How Big?"
			@modal_body = "1 Story = 0-20' or roughly the size of a 1 story house <br /><br />
						   2 Story = 21-35' or roughtly the size of a two story house <br /><br />
						   3+ Story = 36'-100' or roughtly the size of a three story house...or BIGGER!".html_safe
		else
			@modal_header = "Error"
			@modal_body = "Content Not Found"
		end
	end

	def email_estimate
		logger.debug "Sending Email..."
		EstimateMailer.estimate_email(params[:estimate_id], params[:email]).deliver_later
		respond_to do |format|
			format.js {}
		end
	end

	private

		# def estimate_params
		# 	params.require(:estimate).permit(:name, :date_submitted, :tree_quantity, :address, :labour_hours, :total_cost, :status)
		# end

		def estimate_params
			params.require(:estimate).permit(:status)
		end
end
