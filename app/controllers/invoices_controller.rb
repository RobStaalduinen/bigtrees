class InvoicesController < ApplicationController
  include CustomerEmailRecordable

  layout 'admin'
  before_action :signed_in_user

  def show
    authorize Estimate, :update?

    render json: invoice, serializer: InvoicePreviewSerializer
  end

  def create
    authorize Estimate, :update?

    invoice.update(invoice_params)
    invoice.update(sent_at: Date.today)

    send_final_invoice unless params[:commit] == 'Skip'
    redirect_to estimate_path(invoice.estimate)
  end

  def update
    invoice.update(invoice_params)

    respond_to do |format|
      format.html { redirect_to estimate_path(estimate) }
      format.json { render json: invoice }
    end
  end

  def pay
    invoice.update(invoice_params.merge(paid: true, paid_at: Date.today))
    send_payment_receipt unless params[:commit] == 'Skip'
    redirect_to estimate_path(estimate)
  end

  def pdf
    pdf_quote_path = estimate.pdf_quote
    send_file pdf_quote_path, filename: estimate.pdf_file_name
  end

  private

  def send_final_invoice
    response = QuoteMailer.new.quote_email(estimate, params[:dest_email], params[:subject], params[:content])

    record_customer_email(
      estimate: estimate,
      template_key: params[:template_key],
      nylas_response: response,
      recipient_email: params[:dest_email]
    )
  end

  def send_payment_receipt
    response = InvoiceMailer.new.receipt(estimate, params[:dest_email], params[:subject], params[:content])

    record_customer_email(
      estimate: estimate,
      template_key: params[:template_key],
      nylas_response: response,
      recipient_email: params[:dest_email]
    )
  end

  def invoice_params
    params.require(:invoice).permit(:estimate_id, :number, :payment_method, :paid, :discount)
  end

  def estimate
    @estimate ||= policy_scope(Estimate).find(params[:estimate_id])
  end

  def invoice
    @invoice ||= Invoice.find(params[:id] || params[:invoice_id])
  end

end
