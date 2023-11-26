# frozen_string_literal: true

class EstimatePolicy < ApplicationPolicy
  attr_reader :user, :estimate

  role_resource :estimates

  def initialize(user, estimate)
    @user = user
    @estimate = estimate
  end

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope, :role

    role_resource :estimates

    def resolve
      if level == 'organization' || level == 'all'
        scope.joins(:arborist).where(arborists: { organization_id: OrganizationContext.current_organization.id })
      else
        scope.joins(:arborist).where(arborist: user)
      end
    end
  end
end
