# frozen_string_literal: true

class EmailInsertablesController < ApplicationController
  before_action :signed_in_user

  def index
    @email_insertables = policy_scope(EmailInsertable).includes(:options)

    # Serialized by hand so the reserved keys can ride along beside the usual
    # `email_insertables` root — the management form needs them to reject a key the model
    # would refuse anyway, before the user submits.
    payload = ActiveModelSerializers::SerializableResource.new(@email_insertables).as_json

    render json: payload.merge(reserved_keys: EmailTemplate::RESERVED_KEYS)
  end

  def create
    email_insertable = OrganizationContext.current_organization.email_insertables.build(email_insertable_params)

    if email_insertable.save
      render json: email_insertable.reload
    else
      render json: email_insertable.errors, status: :unprocessable_entity
    end
  end

  def update
    email_insertable = policy_scope(EmailInsertable).find_by(id: params[:id])

    return head :not_found unless email_insertable

    if email_insertable.update(email_insertable_params)
      render json: email_insertable.reload
    else
      render json: email_insertable.errors, status: :unprocessable_entity
    end
  end

  private

  def email_insertable_params
    params.require(:email_insertable).permit(
      :key,
      :label,
      options_attributes: [:id, :label, :content, :position, :_destroy]
    )
  end
end
