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
      if level == 'self' || level == 'organization'
        scope.joins(:organization_memberships).where(organization_memberships: { arborist_id: user.id })
      elsif level == 'all'
        scope.all
      end
    end
  end
end
