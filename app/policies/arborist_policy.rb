# frozen_string_literal: true

class ArboristPolicy < ApplicationPolicy
  attr_reader :user, :arborist

  role_resource :arborists

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope, :role

    role_resource :arborists

    def resolve
      if level == 'organization'
        scope.where(organization: user.organization)
      else
        scope.where(id: user.id)
      end
    end
  end
end
