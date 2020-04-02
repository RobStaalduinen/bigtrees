class ReceiptsController < ApplicationController
  layout 'admin'

  before_action :signed_in_user

  def index
    authorize! :manage, Receipt
    
    @receipts = current_user.get_receipts.regular.order("date DESC")
    @cheques = current_user.get_receipts.cheque.order("date DESC")
  end

  def new
    authorize! :manage, Receipt

    @arborist = current_user
    @vehicles = Vehicle.all

    @receipt = Receipt.new

    render 'new', layout: 'admin_material'
  end

  def create
    authorize! :manage, Receipt

    current_user.receipts.create(receipt_params)

    redirect_to receipts_path
  end

  def show
    authorize! :manage, Receipt
    
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
