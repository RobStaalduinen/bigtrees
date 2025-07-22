# frozen_string_literal: true

class NylasAccount < ActiveRecord::Base
  belongs_to :organization

  enum status: { active: 'active', unsynced: 'unsynced' }
end