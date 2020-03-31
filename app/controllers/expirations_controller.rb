class ExpirationsController < ApplicationController
  layout 'admin_material'

  before_action :signed_in_user


  def new
    authorize! :manage, Vehicle
    @expiration = Expiration.new
    @vehicle = Vehicle.find(params[:vehicle_id]) if params[:vehicle_id].present?
  end
  
  def edit
    authorize! :manage, Vehicle
    @expiration = Expiration.find(params[:id])
    @is_edit = true
  end

  def create
    @expiration = Expiration.new(expiration_params)

    if @expiration.save
      redirect_to vehicles_path
    else
      flash.now[:error] = "There was a problem creating the expiration."
      render :new
    end
  end

  def update
    @expiration = Expiration.find(params[:id])
    @expiration.update(expiration_params)
    redirect_to vehicles_path
  end

  private
    def expiration_params
      params.require(:expiration).permit(:vehicle_id, :date, :name)
    end

end
