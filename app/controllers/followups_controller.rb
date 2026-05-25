# frozen_string_literal: true

class FollowupsController < ApplicationController
  include CustomerEmailRecordable

  before_action :signed_in_user

  TEMPLATE_TIMESTAMP_FIELDS = {
    'no_response' => :followup_sent_at,
    'image_request' => :picture_request_sent_at
  }.freeze

  def create
    authorize Estimate, :update?

    template = policy_scope(EmailTemplate).find_by(key: params[:template_key], category: 'followup')
    if template.nil?
      return render json: { error: 'invalid followup template' }, status: :unprocessable_entity
    end

    response = QuoteMailer.new.quote_email(
      estimate,
      params[:dest_email],
      params[:subject],
      params[:content],
      include_quote?
    )

    record_customer_email(
      estimate: estimate,
      template_key: params[:template_key],
      nylas_response: response,
      recipient_email: params[:dest_email]
    )

    estimate.update(timestamp_field => Time.current)

    render json: estimate
  end

  private

  def include_quote?
    ActiveModel::Type::Boolean.new.cast(params[:include_quote])
  end

  def timestamp_field
    TEMPLATE_TIMESTAMP_FIELDS[params[:template_key]] || :followup_sent_at
  end

  def estimate
    @estimate ||= policy_scope(Estimate).find(params[:estimate_id])
  end
end
