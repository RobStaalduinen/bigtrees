# frozen_string_literal: true

class OrganizationsController < ApplicationController
  def index
    authorize Organization, :index?

    @organizations = policy_scope(Organization)

    render json: @organizations
  end

  def show
    authorize Organization, :show?

    @organization = policy_scope(Organization).find(params[:id])

    render json: @organization
  end

  def create
    authorize Organization, :create?

    result = Organizations::Create.call(organization_create_params)

    render json: { temporary_password: result[:temporary_password] }, status: :created
  end

  def update
    authorize Organization, :update?

    @organization = policy_scope(Organization).find(params[:id])

    @organization.update(organization_params)

    render json: @organization
  end

  def stats
    authorize Organization, :index?

    organizations = policy_scope(Organization)
    render json: { stats: Organizations::Stats.call(organizations) }
  end

  def public
    @organization = Organization.find_by(short_name: params[:short_name])

    render json: @organization, serializer: OrganizationPublicSerializer
  end

  private

  def organization_create_params
    params.require(:organization).permit(
      :name, :legal_name, :contact_person, :email, :website,
      :logo_url, :primary_colour, :secondary_colour, :monthly_cost
    )
  end

  def organization_params
    params.require(:organization).permit(
      :name, :legal_name, :email, :phone_number, :website, :email_author, :email_signature,
      :outgoing_quote_email, :quote_bcc, :insurance_provider, :insurance_policy_number,
      :insurance_description, :hst_number, :logo_url, :primary_colour, :secondary_colour,
      address_attributes: [:street, :city, :postal_code]
    )
  end
end
