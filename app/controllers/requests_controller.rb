class RequestsController < ApplicationController

  def new

  end

  def create
    estimate = Estimate.create(request_params)

    render json: { estimate_id: estimate.id }
  end

  def update
    estimate = Estimate.find(params[:id])

    estimate.update(request_params)

    if params[:estimate][:submission_completed] && !params[:estimate][:supress_email]
      EstimateMailer.estimate_alert(estimate).deliver_later
    end

    render json: { status: :ok }
  end

  private

    def request_params
      params.require(:estimate).permit(
        :tree_quantity, :street, :city, :wood_removal, :breakables, :vehicle_access,
        :person_name, :email, :phone, :submission_completed, :stumping_only, :access_width,
        :preferred_contact
      )
    end

end
