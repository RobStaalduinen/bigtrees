class CustomerDetailsController < ApplicationController
  layout 'admin'

  before_action :signed_in_user

  def update
    authorize Estimate, :update?

    @customer_detail = CustomerDetail.find(params[:id])

    @customer_detail.update(customer_detail_params)

    if params[:update_parent_customer]
      @customer_detail.estimate.customer.update(customer_detail_params)
    end

    render json: @customer_detail
  end

  def customer_detail_params
    params.require(:customer_detail).permit(
      :name, :email, :phone, address_attributes: [ :id, :street, :city, :_destroy],
    )
  end

end
