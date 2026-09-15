# frozen_string_literal: true

class EmailInsertablesController < ApplicationController
  before_action :signed_in_user

  def index
    @email_insertables = policy_scope(EmailInsertable).includes(:options)

    render json: @email_insertables
  end
end
