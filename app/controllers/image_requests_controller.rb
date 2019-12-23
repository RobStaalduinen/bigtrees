class ImageRequestsController < AdminBaseController

  def new
    @estimate = Estimate.find(params[:estimate_id])
  end

  def create
    @estimate = Estimate.find(params[:estimate_id])

    if @estimate.customer.email.blank?
      @estimate.customer.update(email: params[:dest_email])
    end
    
    QuoteMailer.picture_request(@estimate, params[:dest_email], params[:subject], params[:content]).deliver_now

    redirect_to estimate_path(@estimate)
  end
  
end
