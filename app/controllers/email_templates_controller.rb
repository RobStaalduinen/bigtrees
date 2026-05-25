class EmailTemplatesController < ApplicationController
  before_action :signed_in_user

  def index
    @email_templates = policy_scope(EmailTemplate).all

    render json: @email_templates
  end

  def create
    title = params.dig(:email_template, :title).to_s
    key = EmailTemplate.slugify_title(title)

    if key.blank?
      return render json: { title: ["can't be blank"] }, status: :unprocessable_entity
    end

    email_template = OrganizationContext.current_organization.email_templates.build(
      email_template_params.merge(key: key, category: 'scheduling')
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

    if email_template.category != 'scheduling'
      return render json: { category: ['only scheduling templates can be deleted'] }, status: :unprocessable_entity
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
