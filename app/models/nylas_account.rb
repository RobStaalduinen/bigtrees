# frozen_string_literal: true

class NylasAccount < ActiveRecord::Base
  belongs_to :organization

  enum status: { active: 'active', unsynced: 'unsynced' }

  def validate!
    wrapper = Nylas::Wrapper.new
    wrapper.validate_grant(self)
  end
end