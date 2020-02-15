class CostsController < ApplicationController
  layout 'admin'

  def new
    @estimate = Estimate.find(params[:estimate_id])
    @discount = params[:discount] || false

    @initial_costs = discount ? [{description: '', amount: nil}] : @estimate.trees.map(&:initial_costs).flatten
  end

  def edit
    @estimate = Estimate.find(params[:estimate_id])
    @discount = params[:discount] || false

    @initial_costs = @estimate.costs.where(discount: discount)
  end

  def create
    @estimate = Estimate.find(params[:estimate_id]) 

    create_costs

    @estimate.update(arborist: Arborist.where(id: params[:arborist_id]).last || current_user) unless @estimate.arborist.present?
    
    @estimate.set_status(true)

    respond_to do |format|
      format.json { render json: { status: :ok } }
      format.html { redirect_to estimate_path(@estimate) }
    end
  end

  def update
    @estimate = Estimate.find(params[:estimate_id]) 
    @estimate.costs.where(discount: discount).destroy_all

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
          amount: normalize_amount(cost_params[:amount].to_f, discount),
          description: cost_params[:description],
          discount: discount
        })
      end
    end

    def normalize_amount(amount, discount)
      if discount
        return amount < 0 ? amount : amount * -1
      end
      
      return amount
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
