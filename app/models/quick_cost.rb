# frozen_string_literal: true

# == Schema Information
#
# Table name: quick_costs
#
#  id              :bigint           not null, primary key
#  organization_id :bigint
#  label           :string(255)
#  content         :string(255)
#  default_cost    :decimal(8, 2)    default(0.0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class QuickCost < ActiveRecord::Base
  belongs_to :organization
end
