class QuotesController < ApplicationController

  def index
    @estimate = Estimate.find(params[:estimate_id])

    #file_name = "Quote__#{@estimate.id}"
    
    respond_to do |format| 
      format.xlsx {render xlsx: 'quote', filename: "quote.xlsx"}
   end
  end
end
