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
end
