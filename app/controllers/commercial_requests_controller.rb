# frozen_string_literal: true

class CommercialRequestsController < ApplicationController
  def create
    organization = Organization.find(params[:organization_id])

    EstimateMailer.commercial_quote_request(organization, contact_params).deliver_now

    render json: { status: :ok }
  end

  private

  def contact_params
    params.require(:commercial_request).permit(:name, :email, :phone)
  end
end
