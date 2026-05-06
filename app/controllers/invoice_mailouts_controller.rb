# frozen_string_literal: true

class InvoiceMailoutsController < ApplicationController
  include CustomerEmailRecordable

  before_action :signed_in_user

  def create
    authorize Estimate, :update?

    Invoice.transaction do
      estimate.update(estimate_params) if estimate_params
      invoice.update(invoice_params) if invoice_params
      invoice.assign_number
      invoice.save
      estimate.set_status(true)

      send_mailout
    end

    render json: estimate.reload
  end

  private

  def send_mailout
    authorize Estimate, :update?

    return if params[:skip_mail]

    response = QuoteMailer.new.quote_email(estimate, params[:dest_email], params[:subject], params[:content])

    record_customer_email(
      estimate: estimate,
      template_key: params[:template_key],
      nylas_response: response,
      recipient_email: params[:dest_email]
    )
  end

  def estimate
    @estimate ||= policy_scope(Estimate).find(params[:estimate_id])
  end

  def invoice
    estimate.invoice
  end

  def invoice_params
    params.fetch(:invoice, {}).permit(:number).merge(sent_at: Date.today)
  end

  def estimate_params
    params.fetch(:estimate, {}).permit(:work_completion_date)
  end
end
