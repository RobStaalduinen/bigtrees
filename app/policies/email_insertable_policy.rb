# frozen_string_literal: true

class EmailInsertablePolicy < ApplicationPolicy
  attr_reader :user, :email_insertable

  role_resource :email_templates

  def initialize(user, email_insertable)
    @user = user
    @email_insertable = email_insertable
  end

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope, :role

    role_resource :email_templates

    def resolve
      scope.where(organization: OrganizationContext.current_organization)
    end
  end
end
