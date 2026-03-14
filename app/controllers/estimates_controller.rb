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

    @estimates = base_estimate_query.
      includes(site: [:address]).
      includes(:customer_detail).
      includes(:customer).
      includes(:arborist).
      includes(:tags)

    @estimates = filter_estimates(@estimates, params)

    @estimates = search_estimates(@estimates, params[:q]) if params[:q]

    @estimates = @estimates.paginate(page: params[:page], per_page: params[:per_page])

    render json: @estimates, each_serializer: EstimateListSerializer, meta: { total_entries: @estimates.total_entries }
  end

  def new
    authorize Estimate, :new?

    @customer = Customer.find_by(id: params[:customer_id]) || Customer.new
    @arborist = current_user
    @last_estimate = @customer.estimates.last || Estimate.new
  end

  def show
    authorize Customer, :show?

    @estimate = policy_scope(Estimate).find(params[:id])

    render json: @estimate
  end

  def create
    authorize Estimate, :create?

    estimate = Estimates::Create.call(
      estimate_params:        estimate_params,
      site_params:            params[:site].present? ? site_params : nil,
      customer_params:        params[:customer].present? ? customer_params : nil,
      customer_detail_params: params[:customer].present? ? customer_detail_params : nil,
      job_attributes:         params[:job].present? ? job_attributes : nil,
      org:                    OrganizationContext.current_organization,
      current_user:           current_user,
      policy_scope:           policy_scope(Customer)
    )

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

		@estimate = policy_scope(Estimate).find(params[:id])
		@estimate.update(state: 'cancelled')

    render json: {}
	end

  def stats
    authorize Estimate, :index?

    @estimates = base_estimate_query.in_progress

    @estimates = filter_estimates(@estimates, params)
    @estimates = search_estimates(@estimates, params[:q]) if params[:q]

    stats = {
      needs_costs: @estimates.needs_costs.count,
      quote_sent: @estimates.quote_sent.count,
      approved: @estimates.approved.count,
      scheduled: @estimates.work_scheduled.count,
      completed: @estimates.work_completed.count,
      invoice_sent: @estimates.final_invoice_sent.count
    }
    render json: stats
  end

  private

  def base_estimate_query
    policy_scope(Estimate)
      .joins(:customer)
      .joins(:site)
      .joins(:customer_detail)
      .joins("LEFT JOIN addresses site_addresses ON (site_addresses.addressable_type = 'Site' AND site_addresses.addressable_id = sites.id AND sites.estimate_id = estimates.id)")
      .joins("LEFT JOIN addresses customer_addresses ON (customer_addresses.addressable_type = 'CustomerDetail' AND customer_addresses.addressable_id = customer_details.id AND customer_details.estimate_id = estimates.id)")
      .joins("LEFT JOIN invoices on invoices.estimate_id = estimates.id")
  end

  def search_estimates(estimates, query)
    estimates.where(
      '
        LOWER(customers.name) LIKE :search OR
        LOWER(customers.email) LIKE :search OR
        LOWER(customers.phone) LIKE :search OR
        LOWER(customer_details.name) LIKE :search OR
        LOWER(customer_details.email) LIKE :search OR
        LOWER(customer_details.phone) LIKE :search OR
        LOWER(site_addresses.street) LIKE :search OR
        LOWER(site_addresses.city) LIKE :search OR
        LOWER(customer_addresses.street) LIKE :search OR
        LOWER(customer_addresses.city) LIKE :search OR
        LOWER(invoices.number) LIKE :search
      ',
      search: "%#{query.downcase}%"
    )
  end

  def estimate_params
    e_params = params.require(:estimate).permit(
      :tree_quantity, :state, :state_reason, :status, :arborist_id, :is_unknown, :work_start_date, :work_end_date, :quote_sent_date, :submission_completed, :skip_schedule, :cancelled_at, :pending_permit, :approved,
      equipment_assignments_attributes: [ :vehicle_id ],
      notes_attributes: [
        :content,
        image_attributes: [ :image_url, :edited_url ]
      ],
    )
    e_params[:is_unknown] ||= false
    e_params
  end

  def job_attributes
    params.require(:job).permit(
      :started_at, :completed_at, :job_survey_responses, :completion_notes
    )
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

  def customer_detail_params
    params.require(:customer).permit(
     :name, :phone, :email
    )
  end

  def filter_estimates(estimates, params)
    estimates = estimates.created_after(params[:created_after]) if params[:created_after]
    estimates = estimates.for_status(params[:status]) if params[:status]

    if params[:only_mine]
      estimates = estimates.where(arborist: current_user).order('work_start_date ASC')
    else
      estimates = estimates.order('estimates.id DESC')
    end

    if params[:assigned_to] == 'me'
      estimates = estimates.where(arborist: current_user)
    end

    if params[:tag_ids].present? && params[:tag_ids].any?
      estimates = estimates.with_tags(params[:tag_ids])
    end

    estimates
  end
end
