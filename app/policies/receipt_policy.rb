# frozen_string_literal: true

class ReceiptPolicy < ApplicationPolicy
  attr_reader :user, :receipt

  role_resource :receipts

  def initialize(user, receipt)
    @user = user
    @receipt = receipt
  end

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope, :role

    role_resource :receipts

    def resolve
      if level == 'all' || level == 'organization'
        scope.where(organization_id: OrganizationContext.current_organization.id)
      else
        scope.where(arborist_id: user.id).where(organization: OrganizationContext.current_organization)
      end
    end
  end
end
