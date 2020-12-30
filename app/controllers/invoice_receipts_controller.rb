# frozen_string_literal: true

class InvoiceReceiptsController < ApplicationController
  before_action :signed_in_user

  def create
    Invoice.transaction do
      invoice.update(invoice_params) if invoice_params

      estimate.set_status(true)

      send_mailout
    end

    render json: estimate.reload
  end

  private

  def invoice_params
    params.require(:invoice).permit(:payment_method).merge(paid_at: Date.today, paid: true)
  end

  def email_params
    params.require(:email).permit(:email, :subject, :content)
  end

  def send_mailout
    return unless params[:send_receipt].to_s.downcase == 'true'

    InvoiceMailer.receipt(estimate.reload, email_params[:email], email_params[:subject], email_params[:content]).deliver_now
  end

  def estimate
    @estimate ||= Estimate.find(params[:estimate_id])
  end

  def invoice
    estimate.invoice
  end
end
