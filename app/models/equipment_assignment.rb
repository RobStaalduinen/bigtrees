# frozen_string_literal: true

# == Schema Information
#
# Table name: equipment_assignments
#
#  id          :integer          not null, primary key
#  estimate_id :integer
#  vehicle_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class EquipmentAssignment < ActiveRecord::Base
  belongs_to :estimate
  belongs_to :vehicle
end
