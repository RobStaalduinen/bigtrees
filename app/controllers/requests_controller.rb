class RequestsController < ApplicationController

  def new

  end

  def create
    estimate = Estimate.create(request_params)

    if params[:tree_site].present?
      site = estimate.site || Site.new(estimate: estimate)
      site.update(site_params)
    end

    if params[:customer].present?
      customer = Customer.find_or_create_by_params(customer_params)
      estimate.update(customer: customer)

      customer_detail = estimate.customer_detail || CustomerDetail.new(estimate: estimate)
      customer_detail.update(customer_detail_params)
    end

    render json: { estimate_id: estimate.id }
  end

  def update
    estimate = Estimate.find(params[:id])
    estimate.update(request_params)

    if params[:tree_site].present?
      site = estimate.site || Site.new(estimate: estimate)
      site.update(site_params)
    end

    if params[:customer].present?
      customer = Customer.find_or_create_by_params(customer_params)
      estimate.update(customer: customer)

      customer_detail = estimate.customer_detail || CustomerDetail.new(estimate: estimate)
      customer_detail.update(customer_detail_params)
    end

    if params[:estimate][:submission_completed] && !params[:estimate][:supress_email]
      EstimateMailer.estimate_alert(estimate).deliver_later
    end

    render json: { status: :ok }
  end

  private

    def request_params
      params.require(:estimate).permit(
        :tree_quantity, :submission_completed, :stumping_only,
      ).merge({ arborist_id: Arborist::DEFAULT_ID, organization_id: 1 }) # TODO: Change this when having whitelabed request page
    end

    def site_params
      params.require(:tree_site).permit(
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

    def customer_detail_params
      params.require(:customer).permit(
       :name, :phone, :email
      )
    end
end
