# frozen_string_literal: true

class ApprovalMailoutsController < ApplicationController
  include CustomerEmailRecordable

  before_action :signed_in_user

  def create
    authorize Estimate, :update?
    @estimate = policy_scope(Estimate).find(params[:estimate_id])

    response = QuoteMailer.new.quote_email(
      @estimate,
      params[:dest_email],
      params[:subject],
      params[:content],
      false
    )

    record_customer_email(
      estimate: @estimate,
      template_key: template_key,
      nylas_response: response,
      recipient_email: params[:dest_email]
    )

    render json: @estimate
  end

  private

  # The send form offers every template in this category, so record whichever one was used.
  def template_key
    params[:template_key].presence || 'approval_mailout'
  end
end
