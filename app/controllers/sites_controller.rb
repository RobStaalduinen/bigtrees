class SitesController < ApplicationController

  def create
    estimate = Estimate.find(params[:estimate_id])
    estimate.site = Site.create(site_params)
    estimate.save!

    render json: { status: :ok }
  end

  def site_params
    params.require(:site).permit(
      :street, :city, :wood_removal, :breakables, :vehicle_access, :access_width
    )
  end
end
