class ReceiptsController < ApplicationController
  layout 'admin'

  before_action :signed_in_user

  def index
    @receipts = current_user.get_receipts.regular.order("date DESC")
    @cheques = current_user.get_receipts.cheque.order("date DESC")
  end

  def new
    @arborist = current_user
    @all_arborists = Arborist.real
    @vehicles = Vehicle.all
  end

  def create
    Receipt.create(receipt_params)

    redirect_to estimates_path
  end

  def show
    @receipt = Receipt.find(params[:id])
  end

  def xlsx
    @receipts = current_user.get_receipts.regular.order("date DESC")

    respond_to do |format| 
      format.xlsx {render xlsx: 'receipts', filename: "receipts.xlsx"}
    end
  end

  def cheque_xlsx
    @cheques = current_user.get_receipts.cheque.order("date DESC")

    respond_to do |format| 
      format.xlsx {render xlsx: 'cheques', filename: "cheques.xlsx"}
    end
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
