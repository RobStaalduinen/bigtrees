# frozen_string_literal: true

class CustomerDetail < ActiveRecord::Base
  include SingleAddressable

  belongs_to :estimate
end
