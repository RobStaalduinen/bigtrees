class VehiclesController < ApplicationController
  layout 'admin_material'

  before_action :signed_in_user

  def index
    @vehicles = Vehicle.all.includes(:expirations)

    respond_to do |format|
      format.json { render json: @vehicles }
      format.html
    end
  end

  def new
    @vehicle = Vehicle.new
  end

  def show
    @vehicle = Vehicle.find(params[:id])
    @equipment_requests = @vehicle.equipment_requests
  end

  def create
    vehicle = Vehicle.create(vehicle_params)

    redirect_to vehicle_path(vehicle)
  end

  def edit
    @vehicle = Vehicle.find(params[:id])
    @is_edit = true
  end

  def update
    vehicle = Vehicle.find(params[:id])
    vehicle.update(vehicle_params)
    redirect_to vehicle_path(vehicle)
  end

  private

    def vehicle_params
      params.require(:vehicle).permit(:name)
    end
end
