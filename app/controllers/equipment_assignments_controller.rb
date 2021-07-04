class EquipmentAssignmentsController < ApplicationController
  before_action :signed_in_user

  def bulk_update
    estimate.equipment_assignments.destroy_all

    estimate.update(estimate_params)

    render json: estimate
  end

  private

  def estimate_params
    params.require(:estimate).permit(
      equipment_assignments_attributes: [ :vehicle_id ]
    )
  end

  def estimate
    @estimate ||= policy_scope(Estimate).find(params[:estimate_id])
  end
end
