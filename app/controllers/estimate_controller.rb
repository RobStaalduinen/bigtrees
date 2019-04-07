class EstimateController < ApplicationController
	require 'date'

	def new

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

	private

		def estimate_params
			params.require(:estimate).permit(
				:status, :arborist_id, :invoice_number, :discount_applied, :payment_method,
				:person_name, :phone, :email, :street, :city, :quote_accepted_date
			)
		end
end
