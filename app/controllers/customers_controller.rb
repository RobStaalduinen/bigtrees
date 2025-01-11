class CustomersController < ApplicationController
  layout 'admin'

  before_action :signed_in_user

  def index
    authorize Customer, :index?

    @customers = policy_scope(Customer).order('customers.id DESC').includes(:estimates)
    if params[:q]
      @customers = @customers.where(
        'LOWER(name) LIKE :value OR LOWER(email) LIKE :value',
        value: "%#{params[:q].downcase}%"
      )
    end

    @customers = @customers.paginate(page: params[:page], per_page: params[:per_page])

    json_customers = @customers.map { |customer| CustomerSerializer.new(customer).as_json }
    
    render json: { customers: json_customers, total_entries: @customers.total_entries }
  end

  def show
    authorize Customer, :show?

    @customer = policy_scope(Customer).find(params[:id])

    render json: @customer, serializer: CustomerSerializer, include_addresses: true
  end

  def create
    authorize Customer, :create?

    @customer = Customer.create(customer_params)

    render json: @customer
  end

  def update
    authorize Customer, :update?

    @customer = Customer.find(params[:id])
    @customer.update(customer_params)

    # Refactor to some sort of session
    respond_to do |format|
      format.html { redirect_to params[:customer][:redirect_location] || customer_path(id: @customer.id) }
      format.json { render json: @customer }
    end
  end

  def customer_params
    params.require(:customer).permit(
      :name, :email, :phone, address_attributes: [ :id, :street, :city, :_destroy]
    )
  end

end
