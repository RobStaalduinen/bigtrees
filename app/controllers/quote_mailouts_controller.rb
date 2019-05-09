class QuoteMailoutsController < ApplicationController
	include UserHelper

  before_action :signed_in_user

  def new
    @estimate = Estimate.find(params[:estimate_id])
    @is_final = params[:is_final] == 'true'
  end

  def create
    @estimate = Estimate.find(params[:estimate_id])

    unless estimate_params.blank?
      @estimate.update(estimate_params)
    end

    unless params[:skip]
      if @estimate.email.blank?
        @estimate.update(email: params[:dest_email])
      end

      QuoteMailer.quote_email(@estimate, params[:dest_email], params[:subject], params[:content]).deliver_now
    end

    if params[:is_final] == 'true' && @estimate.final_invoice_sent_at.blank?
      @estimate.update(final_invoice_sent_at: Date.today)
    elsif @estimate.quote_sent_date.blank?
      @estimate.update(quote_sent_date: Date.today)
    end


    redirect_to admin_estimates_path(id: params[:estimate_id])
  end

  private

  def estimate_params
    return {} unless params[:estimate].present?
    params.require(:estimate).permit(:discount_applied, :invoice_number)
  end

end
