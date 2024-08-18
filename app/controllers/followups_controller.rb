# frozen_string_literal: true

class FollowupsController < ApplicationController
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
    QuoteMailer.quote_email(
        estimate,
        params[:dest_email],
        params[:subject],
        params[:content],
        should_include_quote
    ).deliver_now
  end

  def estimate
    @estimate ||= policy_scope(Estimate).find(params[:estimate_id])
  end

  def estimate_params
    params.permit(:followup_sent_at, :picture_request_sent_at)
  end
end
