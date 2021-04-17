class EquipmentRequestsController < ApplicationController
  layout 'admin_material'

  before_action :signed_in_user

  def index
    @equipment_requests = EquipmentRequest.all.includes(:vehicle).includes(:arborist).order('created_at DESC')

    if params[:state] == 'resolved'
      @equipment_requests = @equipment_requests.resolved
    else
      @equipment_requests = @equipment_requests.submitted
    end

    render json: @equipment_requests, include: [:vehicle, :arborist]
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
    @equipment_request.arborist = current_user
    @equipment_request.submitted_at = Time.now
    @equipment_request.save

    render json: @equipment_request
  end

  def resolve
    @equipment_request = EquipmentRequest.find(params[:equipment_request_id])
    @equipment_request.update(equipment_request_parameters)
    @equipment_request.resolve! if @equipment_request.may_resolve?

    redirect_to equipment_requests_path
  end

  def send_mailout
    @equipment_request = EquipmentRequest.find(params[:equipment_request_id])

    EquipmentRequestMailer.request_email(
      @equipment_request,
      params[:dest_email],
      params[:subject],
      params[:content]
    ).deliver_now

    render json: {}, status: 200
  end


  private

  def equipment_request_parameters
    params.require(:equipment_request).permit(:category, :description, :image_url, :vehicle_id, :submitted_at, :resolution_notes)
  end
end
