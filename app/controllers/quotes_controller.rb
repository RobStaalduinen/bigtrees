class QuotesController < ApplicationController
  require 'libreconv'
  def index
    @estimate = Estimate.find(params[:estimate_id])

    #file_name = "Quote__#{@estimate.id}"

    # pdf_html = ActionController::Base.new.render_to_string('quotes/pdf/main.html.erb')
    # pdf = WickedPdf.new.pdf_from_string(pdf_html)
    # save_path = Rails.root.join('tmp', 'pdfs','filename.pdf')
    # pdf
    respond_to do |format|
      # format.xlsx {
      #   estimate_file = GenerateQuote.call(@estimate)
      #   send_file estimate_file, filename: "Quote__Estimate_#{@estimate.id}.xlsx"
      # }
      format.pdf{
        pdf_quote_path = @estimate.pdf_quote
        send_file pdf_quote_path, filename: @estimate.pdf_file_name
      }
    end
  end

  def pdf
    @estimate = Estimate.find(params[:estimate_id])

    render 'quotes/pdf/main', layout: 'pdf'
  end

  def receipt
    @estimate = Estimate.find(params[:estimate_id])
    pdf_receipt_path = @estimate.invoice.pdf_receipt
    send_file pdf_receipt_path, filename: "#{@estimate.customer.first_name}-Receipt.pdf"
  end
end
