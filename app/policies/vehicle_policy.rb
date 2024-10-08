# frozen_string_literal: true

class VehiclePolicy < ApplicationPolicy
  attr_reader :user, :resource

  role_resource :vehicles

  def initialize(user, resource)
    @user = user
    @resource = resource
  end

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope, :role

    role_resource :vehicles

    def resolve
      if level == 'all'
        scope.where(organization: OrganizationContext.current_organization)
      else
        scope.where(organization: OrganizationContext.current_organization)
      end
    end
  end
end
