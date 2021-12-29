# frozen_string_literal: true

class EquipmentRequestPolicy < ApplicationPolicy
  attr_reader :user, :resource

  role_resource :equipment_requests

  def initialize(user, resource)
    @user = user
    @resource = resource
  end

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope, :role

    role_resource :equipment_requests

    def resolve
      if user.role == 'mechanic'
        scope.where(mechanic: user)
      elsif level == 'organization'
        scope.where(arborist: user.organization.arborists)
      else
        scope.where(arborist: user)
      end
    end
  end
end
