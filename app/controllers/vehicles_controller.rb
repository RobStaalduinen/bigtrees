class VehiclesController < ApplicationController
  layout 'admin_material'

  before_action :signed_in_user

  def index
    @vehicles = policy_scope(Vehicle).includes(:expirations)

    respond_to do |format|
      format.json { render json: @vehicles.order(id: :asc) }
      format.html
    end
  end

  def show
    @vehicle = policy_scope(Vehicle).find(params[:id])
    @equipment_requests = @vehicle.equipment_requests
  end

  def create
    vehicle = Vehicle.create(vehicle_params.merge({ organization_id: current_user.organization_id }))

    render json: vehicle
  end


  def update
    vehicle = policy_scope(Vehicle).find(params[:id])
    vehicle.update(vehicle_params)

    render json: vehicle
  end

  def destroy
    vehicle = Vehicle.find(params[:id])
    vehicle.destroy

    render json: {}
  end

  private

    def vehicle_params
      params.require(:vehicle).permit(:name)
    end
end
