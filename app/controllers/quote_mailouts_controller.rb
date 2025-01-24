class QuoteMailoutsController < ApplicationController
  layout 'admin'

  before_action :signed_in_user

  def create
    authorize Estimate, :update?

    @estimate = Estimate.find(params[:estimate_id])
    send_email unless params[:skip]
    @estimate.update(estimate_params)

    respond_to do |format|
      format.html { redirect_to (params[:redirect] || estimate_path(@estimate)) }
      format.json { render json: @estimate }
    end
  end

  private

  def send_email
    QuoteMailer.quote_email(
      @estimate,
      params[:dest_email],
      params[:subject],
      params[:content]
  ).deliver_now
  end

  def estimate_params
    params.permit(:quote_sent_date, :is_unknown, :followup_sent_at)
  end
end
