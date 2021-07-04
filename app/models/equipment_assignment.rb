# frozen_string_literal: true

class EquipmentAssignment < ActiveRecord::Base
  belongs_to :estimate
  belongs_to :vehicle
end
