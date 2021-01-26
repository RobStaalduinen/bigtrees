class EstimatesController < ApplicationController
  require 'date'
  layout 'admin'

  before_action :signed_in_user, except: %i[create update]

  def index
    authorize! :query, Estimate
    if request.format.html?
      redirect_to '/admin/estimates'
      return
    end

    if current_user.admin?
      @estimates = Estimate.all
    else
      @estimates = current_user.estimates
    end

    @estimates = @estimates.submitted.
      order('estimates.id DESC').
      joins(:customer).
      joins(:site).
      includes(customer: [:address]).
      includes(site: [:address]).
      includes(:invoice).
      includes(:arborist).
      includes(:costs).
      includes(trees: [:tree_images])

    @estimates = @estimates.created_after(params[:created_after]) if params[:created_after]
    @estimates = @estimates.for_status(params[:status]) if params[:status]
    @estimates = search_estimates(@estimates, params[:q]) if params[:q]

    @estimates = @estimates.paginate(page: params[:page], per_page: params[:per_page])

    render json: @estimates, meta: { total_entries: @estimates.total_entries }
  end

  def new
    authorize! :manage, Estimate

    @customer = Customer.find_by(id: params[:customer_id]) || Customer.new
    @arborist = current_user
    @last_estimate = @customer.estimates.last || Estimate.new
  end

  def show
    @estimate = Estimate.find(params[:id])
    authorize! :read, @estimate

    render json: @estimate
	end

	def create
    estimate = Estimate.create(request_params)
    estimate.update(arborist: current_user)

		render json: { estimate_id: estimate.id }
	end

  def update
    @estimate = Estimate.find(params[:id])
		@estimate.update(estimate_params)
		@estimate.set_status

		respond_to do |format|
			format.json { render json: @estimate }
			format.html { redirect_to estimate_path(@estimate) }
		end
  end

	def edit
		authorize! :manage, Estimate

		@estimate = Estimate.find(params[:id])

		if params[:form_option] == 'set_work_date'
			render template: "estimates/edit/#{params[:form_option]}", layout: 'admin_material'
		else
			render template: "estimates/edit/#{params[:form_option]}"
		end
	end

	def cancel
		authorize! :manage, Estimate

		@estimate = Estimate.find(params[:id])
		@estimate.update(cancelled_at: Date.today)
		redirect_to estimate_path(@estimate)
	end

  private

  def search_estimates(estimates, query)
    estimates.where(
      '
        LOWER(customers.name) LIKE :search OR
        LOWER(customers.email) LIKE :search OR
        LOWER(customers.phone) LIKE :search OR
        LOWER(sites.street) LIKE :search OR
        LOWER(sites.city) LIKE :search
      ',
      search: "%#{query.downcase}%"
    )
  end

  def estimate_params
    e_params = params.require(:estimate).permit(
      :status, :arborist_id, :is_unknown, :work_date, :quote_sent_date
    )
    e_params[:is_unknown] ||= false
    e_params
  end
end
