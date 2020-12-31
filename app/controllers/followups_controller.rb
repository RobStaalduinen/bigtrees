# frozen_string_literal: true

class FollowupsController < ApplicationController

  def create
    should_include_quote = params[:include_quote] == true
    QuoteMailer.quote_email(
        estimate,
        params[:dest_email],
        params[:subject],
        params[:content],
        should_include_quote
    ).deliver_now

    estimate.update(estimate_params)

    render json: estimate
  end

  private

  def estimate
    @estimate ||= Estimate.find(params[:estimate_id])
  end

  def estimate_params
    params.permit(:followup_sent_at, :picture_request_sent_at)
  end
end
