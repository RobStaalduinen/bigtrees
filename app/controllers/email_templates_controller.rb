class EmailTemplatesController < ApplicationController
  before_action :signed_in_user

  def index
    @email_templates = policy_scope(EmailTemplate).all

    render json: @email_templates
  end

  def create
    title = params.dig(:email_template, :title).to_s
    key = EmailTemplate.slugify_title(title)
    category = params.dig(:email_template, :category).to_s

    if key.blank?
      return render json: { title: ["can't be blank"] }, status: :unprocessable_entity
    end

    unless EmailTemplate::USER_MANAGED_CATEGORIES.include?(category)
      return render json: { category: ["must be one of #{EmailTemplate::USER_MANAGED_CATEGORIES.join(', ')}"] }, status: :unprocessable_entity
    end

    email_template = OrganizationContext.current_organization.email_templates.build(
      email_template_params.merge(key: key, category: category)
    )

    if email_template.save
      render json: email_template
    else
      render json: email_template.errors, status: :unprocessable_entity
    end
  end

  def update
    email_template = policy_scope(EmailTemplate).find_by(key: params[:id])

    if email_template.update(email_template_params)
      render json: email_template
    else
      render json: email_template.errors, status: :unprocessable_entity
    end
  end

  def destroy
    email_template = policy_scope(EmailTemplate).find_by(key: params[:id])

    return head :not_found unless email_template

    unless EmailTemplate::USER_MANAGED_CATEGORIES.include?(email_template.category)
      return render json: { category: ['this template cannot be deleted'] }, status: :unprocessable_entity
    end

    email_template.destroy
    head :no_content
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
