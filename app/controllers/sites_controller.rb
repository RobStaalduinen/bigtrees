class SitesController < ApplicationController
  def create
    site = Site.new(site_params)
    site.estimate_id = estimate.id
    site.save

    estimate.save

    render json: { status: :ok }
  end

  def update
    authorize Estimate, :update?

    @site = Site.where(estimate: estimate).find(params[:id])
    @site.update(site_params)

    respond_to do |format|
      format.html { redirect_to estimate_path(id: params[:estimate_id]) }
      format.json { render json: @site }
    end
  end

  private

  def estimate
    @estimate ||= policy_scope(Estimate).find(params[:estimate_id])
  end

  def site_params
    params.require(:tree_site).permit(
      :wood_removal, :breakables, :vehicle_access, :low_access_width, :cleanup,
      address_attributes: [ :id, :street, :city ]
    )
  end
end
