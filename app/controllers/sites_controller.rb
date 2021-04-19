class SitesController < ApplicationController

  def edit
    @estimate = Estimate.find(params[:estimate_id])
    @site = @estimate.site
  end

  def create
    puts 'SITE CREATION'
    puts site_params
    puts 'END SITE CREATION'

    estimate = Estimate.find(params[:estimate_id])
    site = Site.new(site_params)
    site.estimate_id = estimate.id
    site.save

    estimate.save

    render json: { status: :ok }
  end

  def update
    @site = Site.find(params[:id])
    @site.update(site_params)

    respond_to do |format|
      format.html { redirect_to estimate_path(id: params[:estimate_id]) }
      format.json { render json: @site }
    end
  end

  def site_params
    params.require(:tree_site).permit(
      :wood_removal, :breakables, :vehicle_access, :low_access_width, :cleanup,
      address_attributes: [ :id, :street, :city ]
    )
  end
end
