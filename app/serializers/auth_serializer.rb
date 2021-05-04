# frozen_string_literal: true

class AuthSerializer < ApplicationSerializer
  attribute :name
  attribute :email

  # Virtual
  attribute :role_permissions

end
