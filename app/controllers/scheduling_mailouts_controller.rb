# frozen_string_literal: true

class SchedulingMailoutsController < ApplicationController
  include CustomerEmailRecordable

  before_action :signed_in_user

  def create
    authorize Estimate, :update?
    @estimate = policy_scope(Estimate).find(params[:estimate_id])

    template = policy_scope(EmailTemplate).find_by(key: params[:template_key], category: 'scheduling')
    if template.nil?
      render json: { error: 'invalid scheduling template' }, status: :unprocessable_entity
      return
    end

    response = QuoteMailer.new.quote_email(
      @estimate,
      params[:dest_email],
      params[:subject],
      params[:content],
      false
    )

    record_customer_email(
      estimate: @estimate,
      template_key: params[:template_key],
      nylas_response: response,
      recipient_email: params[:dest_email]
    )

    render json: @estimate
  end
end
