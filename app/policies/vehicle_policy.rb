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
      puts level
      if level == 'all'
        scope.where(organization: Organization.find(1))
      else
        scope.where(organization: user.organization)
      end
    end
  end
end
