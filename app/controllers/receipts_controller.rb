class ReceiptsController < ApplicationController
  before_action :signed_in_user
  before_action :set_receipt, only: %i[show approve update]

  def index
    authorize Receipt, :index?

    receipts = policy_scope(Receipt).regular.order('date DESC')

    state = params[:state] || 'pending'
    receipts = receipts.where(state: state)

    render json: receipts
  end

  def summaries
    authorize Receipt, :index?

    receipts = policy_scope(Receipt).pending

    report = receipts.
      group(:arborist).
      sum(:cost).map do |arborist, cost|
        [arborist.name, cost.to_f]
      end.to_h

    render json: report
  end

  def create
    authorize Receipt, :create?

    receipt = current_user.receipts.new(receipt_params)
    receipt.date ||= Date.today
    receipt.save
    # receipt.update(approved: true) if current_user.admin?

    render json: receipt
  end

  def update
    authorize Receipt, :update?

    @receipt.update(receipt_params)

    render json: @receipt
  end

  def show
    authorize Receipt, :show?

    render json: @receipt
  end

  def approve
    authorize Receipt, :admin?

    @receipt.update(state: :approved)

    render json: @receipt
  end

  def approve_all
    authorize Receipt, :admin?

    policy_scope(Receipt).pending.update_all(state: :approved)

    render json: {}
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
    params.require(:receipt).permit(
      :date, :vehicle_id, :category, :job,
      :payment_method, :cost, :category,
      :description, :photo, :image_url, :rejection_reason, :state
    ).merge({ organization_id: OrganizationContext.current_organization.id })
  end

  def set_receipt
    @receipt = policy_scope(Receipt).find(params[:id] || params[:receipt_id])
  end
end
