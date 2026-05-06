# frozen_string_literal: true

class InvoiceReceiptsController < ApplicationController
  include CustomerEmailRecordable

  before_action :signed_in_user

  def create
    authorize Estimate, :update?

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
    params.require(:email).permit(:subject, :content, :template_key, :email => [])
  end

  def send_mailout
    return unless params[:send_receipt].to_s.downcase == 'true'

    response = InvoiceMailer.new.receipt(
      estimate.reload,
      email_params[:email],
      email_params[:subject],
      email_params[:content]
    )

    record_customer_email(
      estimate: estimate,
      template_key: email_params[:template_key],
      nylas_response: response,
      recipient_email: email_params[:email]
    )
  end

  def estimate
    @estimate ||= policy_scope(Estimate).find(params[:estimate_id])
  end

  def invoice
    estimate.invoice
  end
end
