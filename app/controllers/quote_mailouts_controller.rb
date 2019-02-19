class QuoteMailoutsController < ApplicationController
	include UserHelper

  before_action :signed_in_user

  def new
    @estimate = Estimate.find(params[:estimate_id])
    @is_final = params[:is_final] == 'true'
  end

  def create
    @estimate = Estimate.find(params[:estimate_id])

    QuoteMailer.quote_email(@estimate, params[:dest_email], params[:subject], params[:content]).deliver_now

    if params[:is_final]
      @estimate.update(final_invoice_sent_at: Date.today)
    else
      @estimate.update(quote_sent_date: Date.today)
    end

    redirect_to admin_estimates_path(id: params[:estimate_id])
  end

end
