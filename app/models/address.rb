# frozen_string_literal: true

class Address < ActiveRecord::Base
  def serialized
    slice(:id, :street, :city, :postal_code)
  end

  def full_address
		[street, city, postal_code].join(', ')
  end
end
