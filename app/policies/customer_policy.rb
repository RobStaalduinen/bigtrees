# frozen_string_literal: true

class CustomerPolicy < ApplicationPolicy
  attr_reader :user, :estimate

  role_resource :estimates

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope, :role

    role_resource :estimates

    def resolve
      if level == 'organization' || level == 'all'
          scope.joins(:estimates).where(estimates: { arborist_id: OrganizationContext.current_organization.arborists.select(:id) }).distinct
      else
          scope.joins(:estimates).where(estimates: { arborist: user }).distinct
      end
    end
  end
end
