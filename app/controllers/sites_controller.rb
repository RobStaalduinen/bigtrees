class SitesController < ApplicationController

  def edit
    @estimate = Estimate.find(params[:estimate_id])
    @site = @estimate.site
  end

  def create
    estimate = Estimate.find(params[:estimate_id])
    estimate.site = Site.create(site_params)
    estimate.save!

    render json: { status: :ok }
  end

  def update
    @site = Site.find(params[:id])
    @site.update(site_params)

    redirect_to estimate_path(id: params[:estimate_id])
  end

  def site_params
    params.require(:site).permit(
      :street, :city, :wood_removal, :breakables, :vehicle_access, :access_width
    )
  end
end
