# frozen_string_literal: true

class EmailRecordsController < ApplicationController
  before_action :signed_in_user

  def index
    estimate = policy_scope(Estimate).find(params[:estimate_id])
    email_records = estimate.email_records.order(sent_at: :desc)

    render json: email_records
  end
end
