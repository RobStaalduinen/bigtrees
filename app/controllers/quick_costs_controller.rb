# frozen_string_literal: true

class QuickCostsController < ApplicationController
  before_action :signed_in_user

  def index
    authorize QuickCost, :index?

    organization = policy_scope(Organization).find(params[:organization_id])

    render json: organization.quick_costs
  end

  def create
    authorize QuickCost, :create?

    organization = policy_scope(Organization).find(params[:organization_id])

    @cost = organization.quick_costs.create(quick_cost_params)

    render json: @cost
  end

  private

  def quick_cost_params
    params.require(:quick_cost).permit(:label, :content, :default_cost)
  end
end
