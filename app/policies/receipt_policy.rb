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
  end
end
