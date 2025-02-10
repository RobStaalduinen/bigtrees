class VehiclesController < ApplicationController
  before_action :signed_in_user

  def index
    authorize Vehicle, :index?

    @vehicles = policy_scope(Vehicle).includes(:expirations)

    respond_to do |format|
      format.json { render json: @vehicles.order(id: :asc) }
      format.html
    end
  end

  def show
    authorize Vehicle, :show?

    @vehicle = policy_scope(Vehicle).find(params[:id])
    @equipment_requests = @vehicle.equipment_requests
  end

  def create
    authorize Vehicle, :create?

    vehicle = Vehicle.create(vehicle_params.merge({ organization_id: OrganizationContext.current_organization.id }))

    render json: vehicle
  end


  def update
    authorize Vehicle, :update?

    vehicle = policy_scope(Vehicle).find(params[:id])
    vehicle.update(vehicle_params)

    render json: vehicle
  end

  def destroy
    authorize Vehicle, :destroy?

    vehicle = Vehicle.find(params[:id])
    vehicle.destroy

    render json: {}
  end

  private

    def vehicle_params
      params.require(:vehicle).permit(:name)
    end
end
