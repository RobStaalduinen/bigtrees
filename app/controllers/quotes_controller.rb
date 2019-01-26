class QuotesController < ApplicationController
  require 'libreconv'
  def index
    @estimate = Estimate.find(params[:estimate_id])

    #file_name = "Quote__#{@estimate.id}"
    
    estimate_file = GenerateQuote.call(@estimate)

    respond_to do |format| 
      format.xlsx {
        send_file estimate_file, filename: "Quote__Estimate_#{@estimate.id}.xlsx"
      }
      format.pdf{
        pdf_quote_path = @estimate.pdf_quote
        send_file pdf_quote_path, filename: "#{@estimate.first_name}-#{@estimate.street}-#{@estimate.city}.pdf"
      }
    end
  end
end
