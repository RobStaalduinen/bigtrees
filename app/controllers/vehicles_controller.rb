class VehiclesController < ApplicationController
	include UserHelper

  before_action :signed_in_user

  def index
    @vehicles = Vehicle.all
  end

  def new
    
  end

  def create
    Vehicle.create(vehicle_params)

    redirect_to "/admin/admin_panel"
  end

  private

    def vehicle_params
      params.require(:vehicle).permit(:name)
    end
end
