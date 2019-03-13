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

	def create

	end

	def update
		@estimate = Estimate.find(params[:id])
		@estimate.update(estimate_params)
		@estimate.set_status
		
		redirect_to admin_estimates_path(id: @estimate.id)
	end

	def assign_arborist
		@estimate = Estimate.find(params[:id])
		@arborists = Arborist.real
	end
	
	def finalize_payment
		@estimate = Estimate.find(params[:id])
	end

	def update_contact_details
		@estimate = Estimate.find(params[:id])
	end

	def update_address
		@estimate = Estimate.find(params[:id])
	end

	def cancel
		@estimate = Estimate.find(params[:id])
		@estimate.update(cancelled_at: Date.today)
		redirect_to admin_estimates_path(id: @estimate.id)
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

	private

		# def estimate_params
		# 	params.require(:estimate).permit(:name, :date_submitted, :tree_quantity, :address, :labour_hours, :total_cost, :status)
		# end

		def estimate_params
			params.require(:estimate).permit(
				:status, :arborist_id, :invoice_number, :discount_applied, :payment_method,
				:person_name, :phone, :email, :street, :city
			)
		end
end
