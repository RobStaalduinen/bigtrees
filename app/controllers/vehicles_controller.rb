class VehiclesController < ApplicationController
  layout 'admin'

  before_action :signed_in_user

  def index
    @vehicles = Vehicle.all
  end

  def new
    
  end

  def create
    Vehicle.create(vehicle_params)

    redirect_to estimates_path
  end

  private

    def vehicle_params
      params.require(:vehicle).permit(:name)
    end
end
