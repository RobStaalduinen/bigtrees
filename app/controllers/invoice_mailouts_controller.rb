# frozen_string_literal: true

class InvoiceMailoutsController < ApplicationController
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

    QuoteMailer.quote_email(estimate, params[:dest_email], params[:subject], params[:content]).deliver_now
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
