# frozen_string_literal: true

class TagPolicy < ApplicationPolicy
  attr_reader :user, :tag

  role_resource :tags

  def initialize(user, tag)
    @user = user
    @tag = tag
  end

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope, :role

    role_resource :tags

    def resolve
      if level == 'all' || level == 'organization'
        scope.where(organization_id: OrganizationContext.current_organization.id)
      else
        Tag.none
      end
    end
  end
end