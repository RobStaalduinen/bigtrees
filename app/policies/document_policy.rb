# frozen_string_literal: true

class DocumentPolicy < ApplicationPolicy
  attr_reader :user, :resource

  role_resource :documents

  def initialize(user, resource)
    @user = user
    @resource = resource
  end

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope, :role

    role_resource :documents
  end
end
