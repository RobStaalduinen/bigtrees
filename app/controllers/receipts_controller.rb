class ReceiptsController < ApplicationController
  layout 'admin_material'

  before_action :signed_in_user
  before_action :set_receipt, only: [ :show, :approve ]

  def index
    authorize! :read, Receipt
    @receipts = current_user.get_receipts.regular.order("date DESC")
    @unapproved_per_person = @receipts.
      unapproved.
      group(:arborist).
      sum(:cost).map { |arborist, cost| 
        [arborist.name, cost.to_f] 
      }.to_h
  end

  def new
    authorize! :create, Receipt

    @arborist = current_user
    @vehicles = Vehicle.all

    @receipt = Receipt.new

    render 'new', layout: 'admin_material'
  end

  def create
    authorize! :create, Receipt

    receipt = current_user.receipts.create(receipt_params)
    receipt.update(approved: true) if current_user.admin?

    redirect_to receipts_path
  end

  def show
    authorize! :read, Receipt
  end


  def approve
    authorize! :manage, Receipt

    @receipt.update(approved: true)

    redirect_to receipts_path
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

    def set_receipt
      @receipt = Receipt.find(params[:id] || params[:receipt_id])
    end
end
