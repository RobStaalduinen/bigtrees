class ReceiptsController < ApplicationController
	include UserHelper

  before_action :signed_in_user

  def index
    @receipts = current_user.get_receipts
  end

  def new
    @arborist = current_user
    @all_arborists = Arborist.real
    @vehicles = Vehicle.all
  end

  def create
    Receipt.create(receipt_params)

    redirect_to "/admin/admin_panel"
  end

  private

    def receipt_params
      params.require(:receipt).
             permit(
               :date, :arborist_id, :vehicle_id, :category, :job,
               :payment_method, :cost, :category,
               :description, :photo
             )
    end
end
