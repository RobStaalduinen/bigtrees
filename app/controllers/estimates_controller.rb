class EstimatesController < ApplicationController
	require 'date'
	layout 'admin'

	before_action :signed_in_user, except: [ :create, :update ]

	def index
		@estimates = Estimate.submitted.
			order('estimates.id DESC').
			joins(:customer).
			includes(:customer).
			includes(:site).
			with_customer
	end

	def new
		@customer = Customer.find_by(id: params[:customer_id]) || Customer.new
		@arborist = current_user
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
		
		respond_to do |format|
			format.json { render json: { success: true } }
			format.html { redirect_to estimate_path(@estimate) }
		end
	end

	def edit
		@estimate = Estimate.find(params[:id])

		if params[:form_option] == 'set_work_date'
			render template: "estimates/edit/#{params[:form_option]}", layout: 'admin_material'
		else
			render template: "estimates/edit/#{params[:form_option]}"
		end
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
				:status, :arborist_id, :is_unknown, :work_date
			)
		end
end
