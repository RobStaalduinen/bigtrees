class QuoteMailoutsController < ApplicationController
	include UserHelper

  before_action :signed_in_user

  def new
    @estimate = Estimate.find(params[:estimate_id])
  end

  def create
    
    QuoteMailer.quote_email(params[:dest_email], params[:subject], params[:content]).deliver_now
    redirect_to admin_estimates_path(id: params[:estimate_id])
  end

end
