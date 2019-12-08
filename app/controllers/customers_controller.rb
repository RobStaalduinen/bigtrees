class CustomersController < ApplicationController
  layout 'admin'

  before_action :signed_in_user
  
  def index
    @customers = Customer.with_name.order('name ASC')
  end

  def show
    @customer = Customer.includes(:estimates).find(params[:id])
  end

  def edit
    @customer = Customer.includes(:estimates).find(params[:id])
    @redirect_location = params[:redirect_location]
  end

  def update
    @customer = Customer.includes(:estimates).find(params[:id])
    @customer.update(customer_params)

    # Refactor to some sort of session
    redirect_to params[:customer][:redirect_location] || customer_path(id: @customer.id)
  end

  def customer_params
    params.require(:customer).permit(
      :name, :email, :phone
    )
  end

end
