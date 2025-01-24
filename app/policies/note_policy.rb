# frozen_string_literal: true

class NotePolicy < ApplicationPolicy
  attr_reader :user, :note

  role_resource :notes

  def initialize(user, note)
    @user = user
    @taggnoteing = note
  end

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope, :role

    
    role_resource :notes

    def resolve
      if level == 'all' || level == 'organization'
        scope.joins(:estimate).where(organization_id: OrganizationContext.current_organization.id)
      else
        Note.none
      end
    end
  end
end