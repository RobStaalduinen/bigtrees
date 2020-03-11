class EquipmentRequestsController < ApplicationController
  layout 'admin_material'

  before_action :signed_in_user

  def index
    authorize! :manage, EquipmentRequest
    @equipment_requests = EquipmentRequest.all
  end

  def show
    authorize! :manage, EquipmentRequest
    @equipment_request = EquipmentRequest.find(params[:id])
  end
  
  def new
    authorize! :create, EquipmentRequest
    @equipment_request = EquipmentRequest.new
  end

  def create
    @equipment_request = EquipmentRequest.new(equipment_request_parameters)

    if @equipment_request.save
      @equipment_request.update(arborist: current_user)
      flash[:success] = "Your request has been successfully received."
      redirect_to new_equipment_request_path
    else
      flash.now[:error] = "Something went wrong uploading your request."
      render :new
    end
  end

  def resolve
    authorize! :manage, EquipmentRequest
    @equipment_request = EquipmentRequest.find(params[:equipment_request_id])
    @equipment_request.resolve! if @equipment_request.may_resolve?

    redirect_to equipment_requests_path
  end


  private

    def equipment_request_parameters
      params.require(:equipment_request).permit(:category, :description, :image, :arborist_id, :vehicle_id, :submitted_at)
    end
end
