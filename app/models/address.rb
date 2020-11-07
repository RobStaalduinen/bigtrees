# frozen_string_literal: true

class Address < ActiveRecord::Base
  def serialized
    slice(:id, :street, :city)
  end

  def full_address
		[street, city].join(', ')
  end
end
