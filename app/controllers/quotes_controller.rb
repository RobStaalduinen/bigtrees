class QuotesController < ApplicationController
  require 'libreconv'
  def index
    @estimate = Estimate.find(params[:estimate_id])

    #file_name = "Quote__#{@estimate.id}"

    respond_to do |format| 
      format.xlsx {
        estimate_file = GenerateQuote.call(@estimate)
        send_file estimate_file, filename: "Quote__Estimate_#{@estimate.id}.xlsx"
      }
      format.pdf{
        pdf_quote_path = @estimate.pdf_quote
        send_file pdf_quote_path, filename: "#{@estimate.customer.first_name}-#{@estimate.street}-#{@estimate.city}.pdf"
      }
    end
  end

  def receipt
    @estimate = Estimate.find(params[:estimate_id])
    pdf_receipt_path = @estimate.invoice.pdf_receipt
    send_file pdf_receipt_path, filename: "#{@estimate.customer.first_name}-Receipt.pdf"
  end
end
