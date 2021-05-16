class CostsController < ApplicationController
  layout 'admin'

  def new
    authorize Estimate, :new?

    @estimate = policy_scope(Estimate).find(params[:estimate_id])
    @discount = params[:discount] || false

    @initial_costs = discount ? [{description: '', amount: nil}] : @estimate.trees.map(&:initial_costs).flatten
  end

  def edit
    authorize Estimate, :edit?

    @estimate = policy_scope(Estimate).find(params[:estimate_id])
    @discount = params[:discount] || false

    @initial_costs = @estimate.costs.where(discount: discount)
  end

  def create_single
    authorize Estimate, :create?

    @estimate = policy_scope(Estimate).find(params[:estimate_id])

    @estimate.costs.create(params[:cost].permit(:amount, :description))

    render json: @estimate
  end

  def create
    authorize Estimate, :create?

    @estimate = policy_scope(Estimate).find(params[:estimate_id])

    create_costs

    @estimate.update(arborist: Arborist.where(id: params[:arborist_id]).last || current_user) unless @estimate.arborist.present?

    @estimate.set_status(true)

    respond_to do |format|
      format.json { render json: @estimate }
      format.html { redirect_to estimate_path(@estimate) }
    end
  end

  def update
    authorize Estimate, :update?

    @estimate = policy_scope(Estimate).find(params[:estimate_id])
    @estimate.costs.destroy_all

    create_costs

    @estimate.set_status(true)

    respond_to do |format|
      format.json { render json: @estimate }
      format.html { redirect_to estimate_path(@estimate) }
    end
  end

  private

    def create_costs
      params[:costs].each do |cost_params|
        @estimate.costs.create(cost_params.permit(:amount, :description))
      end
    end

    def discount
      dis = params[:discount]

      if dis == true || dis == false
        return dis
      else
        return dis == "true"
      end
    end
end
