class CostsController < ApplicationController

  def new
    @estimate = Estimate.find(params[:estimate_id])

    @initial_costs = @estimate.trees.map(&:initial_costs).flatten
  end

  def edit
    @estimate = Estimate.find(params[:estimate_id])

    @initial_costs = @estimate.costs
  end

  def create
    @estimate = Estimate.find(params[:estimate_id]) 

    create_costs

    @estimate.set_status(true)

    respond_to do |format|
      format.json { render json: { status: :ok } }
      format.html { redirect_to estimate_path(@estimate) }
    end
  end

  def update
    @estimate = Estimate.find(params[:estimate_id]) 
    @estimate.costs.destroy_all

    create_costs

    respond_to do |format|
      format.json { }
      format.html { redirect_to estimate_path(@estimate) }
    end
  end

  private

    def create_costs
      params[:costs].each do |cost_params|
        @estimate.costs.create({
          amount: cost_params[:amount].to_f,
          description: cost_params[:description],
          discount: cost_params[:amount].to_f < 0.0
        })
      end
    end
end
