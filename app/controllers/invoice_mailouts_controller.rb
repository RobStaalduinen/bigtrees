# frozen_string_literal: true

class InvoiceMailoutsController < ApplicationController
  before_action :signed_in_user

  def create
    Invoice.transaction do
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
    return if params[:skip_mail]

    QuoteMailer.quote_email(estimate, params[:dest_email], params[:subject], params[:content]).deliver_now
  end

  def estimate
    @estimate ||= Estimate.find(params[:estimate_id])
  end

  def invoice
    estimate.invoice
  end

  def invoice_params
    params.fetch(:invoice, {}).permit(:number).merge(sent_at: Date.today)
  end
end
