# frozen_string_literal: true

class EmailTemplatePolicy < ApplicationPolicy
  attr_reader :user, :email_template

  role_resource :email_templates

  def initialize(user, email_template)
    @user = user
    @email_template = email_template
  end

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope, :role

    role_resource :email_templates

    def resolve
      scope.where(organization: OrganizationContext.current_organization)
    end
  end
end
