class QuoteMailoutsController < ApplicationController
  include CustomerEmailRecordable

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
    response = QuoteMailer.new.quote_email(
      @estimate,
      params[:dest_email],
      params[:subject],
      params[:content]
    )

    record_customer_email(
      estimate: @estimate,
      template_key: params[:template_key],
      nylas_response: response,
      recipient_email: params[:dest_email]
    )
  end

  def estimate_params
    params.permit(:quote_sent_date, :is_unknown, :followup_sent_at)
  end
end
