class ExtraCostsController < ApplicationController
  layout 'admin'
  
  def create
    @estimate = Estimate.find(params[:estimate_id])
    @estimate.extra_costs.create(extra_cost_params)

    redirect_to "/admin/edit_extra_costs?id=#{@estimate.id}"
  end

  def destroy
    @estimate = Estimate.find(params[:estimate_id])
    @extra_cost = ExtraCost.find(params[:id])

    @extra_cost.destroy
    redirect_to "/admin/edit_extra_costs?id=#{@estimate.id}"
  end

  private

  def extra_cost_params
    params.require(:extra_cost).permit(:amount, :description)
  end

end
