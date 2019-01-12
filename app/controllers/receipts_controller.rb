class ReceiptsController < ApplicationController
	include UserHelper

  before_action :signed_in_user

  def new
    @arborist = current_user
    @all_arborists = Arborist.real
  end

  def create
    Receipt.create(receipt_params)

    redirect_to "/admin/admin_panel"
  end

  private

    def receipt_params
      params.require(:receipt).
             permit(
               :date, :arborist_id, :category, :job,
               :payment_method, :cost, :category,
               :description, :photo
             )
    end
end
