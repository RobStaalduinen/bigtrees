class EmailTemplatesController < ApplicationController
  before_action :signed_in_user

  def index
    @email_templates = policy_scope(EmailTemplate).all

    render json: @email_templates
  end

  def update
    email_template = policy_scope(EmailTemplate).find_by(key: params[:id])

    if email_template.update(email_template_params)
      render json: email_template
    else
      render json: email_template.errors, status: :unprocessable_entity
    end
  end

  def show
    @email_template = policy_scope(EmailTemplate).find_by(key: params[:id])

    render json: @email_template
  end

  private
  
  def email_template_params
    params.require(:email_template).permit(:subject, :content)
  end
end
