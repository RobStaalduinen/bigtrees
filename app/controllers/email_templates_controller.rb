class EmailTemplatesController < ApplicationController
  before_action :signed_in_user

  def show
    @email_template = policy_scope(EmailTemplate).find_by(key: params[:id])

    render json: @email_template
  end
end
