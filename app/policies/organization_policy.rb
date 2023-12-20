# frozen_string_literal: true

class OrganizationPolicy < ApplicationPolicy
  attr_reader :user, :resource

  role_resource :organizations

  def initialize(user, resource)
    @user = user
    @resource = resource
  end

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope, :role

    role_resource :organizations

    def resolve
      scope.all
    end
  end
end
