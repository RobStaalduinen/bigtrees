class EstimatesController < ApplicationController
	require 'date'
	layout 'admin'

	before_action :signed_in_user

	def index
		@estimates = Estimate.submitted.order('id DESC').joins(:customer).with_customer
	end

	def new
		@customer = Customer.find_by(id: params[:customer_id]) || Customer.new
		@last_estimate = @customer.estimates.last || Estimate.new
	end

	def show
		@estimate = Estimate.find(params[:id])
	end

	def create
		estimate = Estimate.create(request_params)

    render json: { estimate_id: estimate.id }
	end

	def update
		@estimate = Estimate.find(params[:id])
		@estimate.update(estimate_params)
		@estimate.set_status
		
		redirect_to estimate_path(@estimate)
	end

	def assign_arborist
		@estimate = Estimate.find(params[:id])
		@arborists = Arborist.real
	end
	
	def finalize_payment
		@estimate = Estimate.find(params[:id])
	end

	def update_address
		@estimate = Estimate.find(params[:id])
	end

	def cancel
		@estimate = Estimate.find(params[:id])
		@estimate.update(cancelled_at: Date.today)
		redirect_to estimate_path(@estimate)
	end

	def change_trees
		logger.debug "Change Trees Called"
	end

	private

		def estimate_params
			params.require(:estimate).permit(
				:status, :arborist_id, :invoice_number, :discount_applied, :payment_method, :is_unknown
			)
		end
end
