# frozen_string_literal: true

class Address < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true

  def serialized
    slice(:id, :street, :city)
  end

  def full_address
		[street, city].join(', ')
  end
end
