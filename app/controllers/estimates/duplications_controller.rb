class Estimates::DuplicationsController < ApplicationController
  before_action :signed_in_user

  def create
    authorize Estimate, :create?

    new_estimate = Estimates::Duplicate.call(params[:estimate_id])

    render json: { estimate_id: new_estimate.id }
  end
end
