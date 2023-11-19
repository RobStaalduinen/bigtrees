# frozen_string_literal: true

class OrganizationsController < ApplicationController
  def index
    authorize Organization, :index?

    @organizations = policy_scope(Organization)

    render json: @organizations
  end
end
