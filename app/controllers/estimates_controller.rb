class EstimatesController < ApplicationController
  require 'date'
  layout 'admin'

  before_action :signed_in_user, except: %i[update]

  def index
    authorize Estimate, :index?

    if request.format.html?
      redirect_to '/admin/estimates'
      return
    end

    @estimates = policy_scope(Estimate)

    @estimates = @estimates.submitted.
      joins(:customer).
      joins("LEFT OUTER JOIN sites ON sites.estimate_id = estimates.id").
      joins("LEFT OUTER JOIN addresses ON sites.address_id = addresses.id").
      includes(customer: [:address]).
      includes(equipment_assignments: [ :vehicle ]).
      includes(site: [:address]).
      includes(:invoice).
      includes(:arborist).
      includes(:costs).
      includes(trees: [:tree_images])

    @estimates = @estimates.created_after(params[:created_after]) if params[:created_after]
    @estimates = @estimates.for_status(params[:status]) if params[:status]
    if params[:only_mine]
      @estimates = @estimates.where(arborist: current_user).order('work_start_date ASC')
    else
      @estimates = @estimates.order('estimates.id DESC')
    end
    @estimates = search_estimates(@estimates, params[:q]) if params[:q]

    @estimates = @estimates.paginate(page: params[:page], per_page: params[:per_page])
    render json: @estimates, meta: { total_entries: @estimates.total_entries }
  end

  def new
    authorize Estimate, :new?

    @customer = Customer.find_by(id: params[:customer_id]) || Customer.new
    @arborist = current_user
    @last_estimate = @customer.estimates.last || Estimate.new
  end

  def show
    @estimate = policy_scope(Estimate).find(params[:id])
    authorize! :read, @estimate

    render json: @estimate
  end

  def create
    authorize Estimate, :create?

    estimate = Estimate.create(estimate_params)
    estimate.update(arborist: current_user)

    if params[:site].present?
      site = estimate.site || Site.new(estimate: estimate)
      site.update(site_params)
    end

    if params[:customer].present?
      customer = Customer.find_by(id: customer_params[:id]) || Customer.new
      customer.update(customer_params)
      estimate.update(customer: customer)
    end

		render json: { estimate_id: estimate.id }
  end

  def update
    authorize Estimate, :update?

    @estimate = policy_scope(Estimate).find(params[:id])

		@estimate.update(estimate_params)
		@estimate.set_status

		respond_to do |format|
			format.json { render json: @estimate }
			format.html { redirect_to estimate_path(@estimate) }
		end
  end

	def edit
		authorize Estimate, :edit?

		@estimate = policy_scope(Estimate).find(params[:id])

		if params[:form_option] == 'set_work_date'
			render template: "estimates/edit/#{params[:form_option]}", layout: 'admin_material'
		else
			render template: "estimates/edit/#{params[:form_option]}"
		end
	end

	def cancel
		authorize Estimate, :update?

		@estimate = Estimate.find(params[:id])
		@estimate.update(cancelled_at: Date.today)

    render json: {}
	end

  private

  def search_estimates(estimates, query)
    estimates.where(
      '
        LOWER(customers.name) LIKE :search OR
        LOWER(customers.email) LIKE :search OR
        LOWER(customers.phone) LIKE :search OR
        LOWER(sites.street) LIKE :search OR
        LOWER(sites.city) LIKE :search OR
        LOWER(addresses.street) LIKE :search OR
        LOWER(addresses.city) LIKE :search
      ',
      search: "%#{query.downcase}%"
    )
  end

  def estimate_params
    e_params = params.require(:estimate).permit(
      :tree_quantity, :status, :arborist_id, :is_unknown, :work_start_date, :work_end_date, :quote_sent_date, :submission_completed,
      equipment_assignments_attributes: [ :vehicle_id ]
    )
    e_params[:is_unknown] ||= false
    e_params
  end

  def site_params
    params.require(:site).permit(
      :id, :wood_removal, :breakables, :vehicle_access, :cleanup, :access_width, :low_access_width,
      address_attributes: [ :id, :street, :city ]
    )
  end

  def customer_params
    params.require(:customer).permit(
      :id, :name, :phone, :email, :preferred_contact,
      address_attributes: [ :id, :street, :city ]
    )
  end

  def assignment_params
    params.require(:estimate).permit(
      equipment_assignments_attributes: [ :vehicle_id ]
    )
  end
end
