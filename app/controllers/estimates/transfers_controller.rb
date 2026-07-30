class Estimates::TransfersController < ApplicationController
  before_action :signed_in_user

  def create
    # policy_scope proves the current user can access the source estimate in the
    # current (source) org. The target org travels in the body.
    source = policy_scope(Estimate).find(params[:estimate_id])
    authorize source, :transfer?

    new_estimate = Estimates::Transfer.call(source.id, params[:target_organization_id])

    render json: { estimate_id: new_estimate.id }
  rescue Estimates::Transfer::TransferError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
