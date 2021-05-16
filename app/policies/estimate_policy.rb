# frozen_string_literal: true

class EstimatePolicy < ApplicationPolicy
  attr_reader :user, :estimate

  role_resource :estimates

  def initialize(user, estimate)
    @user = user
    @estimate = estimate
  end

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope, :role

    role_resource :estimates
  end
end
