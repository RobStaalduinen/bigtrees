# frozen_string_literal: true

class CustomerPolicy < ApplicationPolicy
  attr_reader :user, :estimate

  role_resource :estimates

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope, :role

    role_resource :estimates

    def resolve
      if level == 'organization'
        Customer.from(
          scope.joins(:estimates).where(estimates: { arborist_id: user.organization.arborists.select(:id) })
        )
      else
        Customer.from(
          scope.joins(:estimates).where(estimates: { arborist: user }).uniq
        )
      end
    end
  end
end
