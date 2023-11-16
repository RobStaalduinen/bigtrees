# frozen_string_literal: true

module Roles
  class SuperAdmin < Roles::Admin
    def default_scope_level
      'all'
    end
  end
end
