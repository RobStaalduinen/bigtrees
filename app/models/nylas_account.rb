# frozen_string_literal: true

class NylasAccount < ActiveRecord::Base
  belongs_to :organization
end