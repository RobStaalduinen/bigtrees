# frozen_string_literal: true

class WorkRecordPolicy < ApplicationPolicy
  attr_reader :user, :receipt

  role_resource :work_records

  def initialize(user, receipt)
    @user = user
    @receipt = receipt
  end

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope, :role

    role_resource :work_records

    def resolve
      if level = 'all' || level = 'organization'
        scope.joins(:arborist).where(arborists: { organization_id: OrganizationContext.current_organization.id })
      else
        scope.joins(:arborist).where(arborist: user)
      end
    end
  end
end
