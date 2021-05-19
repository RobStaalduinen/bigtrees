class ReceiptsController < ApplicationController
  before_action :signed_in_user
  before_action :set_receipt, only: %i[show approve]

  def index
    authorize Receipt, :index?

    # @receipts = current_user.get_receipts.regular.order("date DESC")
    receipts = policy_scope(Receipt).regular.order('date DESC')

    render json: receipts
  end

  def summaries
    authorize Receipt, :index?

    receipts = policy_scope(Receipt).regular.order('date DESC')

    report = receipts.
      unapproved.
      group(:arborist).
      sum(:cost).map do |arborist, cost|
        [arborist.name, cost.to_f]
      end.to_h

    render json: report
  end

  def create
    authorize Receipt, :create?

    receipt = current_user.receipts.create(receipt_params)
    # receipt.update(approved: true) if current_user.admin?

    render json: receipt
  end

  def show
    authorize Receipt, :show?

    render json: @receipt
  end

  def approve
    authorize Receipt, :update?

    @receipt.update(approved: true)

    render json: @receipt
  end

  def xlsx
    authorize Receipt, :admin?

    @receipts = policy_scope(Receipt).regular.order('date DESC')

    respond_to do |format|
      format.xlsx { render xlsx: 'receipts', filename: 'receipts.xlsx' }
    end
  end

  def cheque_xlsx
    authorize Receipt, :admin?

    @cheques = policy_scope(Receipt).cheque.order('date DESC')

    respond_to do |format|
      format.xlsx { render xlsx: 'cheques', filename: 'cheques.xlsx' }
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
    @receipt = policy_scope(Receipt).find(params[:id] || params[:receipt_id])
  end
end
