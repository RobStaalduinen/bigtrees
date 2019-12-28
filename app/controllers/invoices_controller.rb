class InvoicesController < ApplicationController
  layout 'admin'
  before_action :signed_in_user

  def new
    @estimate = Estimate.find(params[:estimate_id])
    @invoice = Invoice.new(estimate: @estimate)
    @invoice.assign_number
  end
  
  def edit
    @invoice = Invoice.find(params[:id])
    render template: "invoices/edit/#{params[:form_option]}"
  end

  def create
    @estimate = Estimate.find(invoice_params[:estimate_id])
    @invoice = @estimate.invoice
    @invoice.update(invoice_params)
    @invoice.update(sent_at: Date.today)
    Cost.create_sign_discount(@invoice.estimate) if invoice_params[:discount] == '1'
    send_final_invoice unless params[:commit] == 'Skip'
    redirect_to estimate_path(@invoice.estimate)
  end

  def update
    @invoice = Invoice.find(params[:id])
    @invoice.update(invoice_params)
    Cost.create_sign_discount(@invoice.estimate) if invoice_params[:discount] == '1'
    send_final_invoice unless params[:commit] == 'Skip'
    redirect_to estimate_path(@invoice.estimate)
  end

  def pay
    @invoice = Invoice.find(params[:invoice_id])
    @invoice.update(invoice_params.merge(paid: true, paid_at: Date.today))
    send_payment_receipt unless params[:commit] == 'Skip'
    redirect_to estimate_path(@invoice.estimate)    
  end

  def send_final_invoice
    QuoteMailer.quote_email(@invoice.estimate, params[:dest_email], params[:subject], params[:content]).deliver_now
  end

  def send_payment_receipt
    InvoiceMailer.receipt(@invoice.estimate, params[:dest_email], params[:subject], params[:content]).deliver_now
  end
  
  def invoice_params
    params.require(:invoice).permit(:estimate_id, :number, :payment_method, :paid, :discount)
  end

end
