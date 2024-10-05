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

  def public
    @organization = Organization.find_by(short_name: params[:short_name])

    render json: {
      primary_colour: @organization.primary_colour,
      secondary_colour: @organization.secondary_colour,
      logo_url: @organization.logo_url
    }
  end
end
