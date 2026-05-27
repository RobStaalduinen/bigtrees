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
      template_key: 'approval_mailout',
      nylas_response: response,
      recipient_email: params[:dest_email]
    )

    render json: @estimate
  end
end
