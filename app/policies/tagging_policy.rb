# frozen_string_literal: true

class TaggingPolicy < ApplicationPolicy
  attr_reader :user, :tagging

  role_resource :taggings

  def initialize(user, tagging)
    @user = user
    @tagging = tagging
  end

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope, :role

    
    role_resource :taggings

    def resolve
      if level == 'all' || level == 'organization'
        scope.joins(:estimate).where(organization_id: OrganizationContext.current_organization.id)
      else
        Tagging.none
      end
    end
  end
end