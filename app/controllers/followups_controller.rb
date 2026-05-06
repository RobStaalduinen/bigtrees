# frozen_string_literal: true

class FollowupsController < ApplicationController
  include CustomerEmailRecordable

  before_action :signed_in_user

  def create
    authorize Estimate, :update?

    send_email unless params[:skip]

    estimate.update(estimate_params)

    render json: estimate
  end

  private

  def send_email
    should_include_quote = params[:include_quote] == true
    response = QuoteMailer.new.quote_email(
      estimate,
      params[:dest_email],
      params[:subject],
      params[:content],
      should_include_quote
    )

    record_customer_email(
      estimate: estimate,
      template_key: params[:template_key],
      nylas_response: response,
      recipient_email: params[:dest_email]
    )
  end

  def estimate
    @estimate ||= policy_scope(Estimate).find(params[:estimate_id])
  end

  def estimate_params
    params.permit(:followup_sent_at, :picture_request_sent_at)
  end
end
