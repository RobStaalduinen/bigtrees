# frozen_string_literal: true

# == Schema Information
#
# Table name: arborists
#
#  id                     :integer          not null, primary key
#  name                   :string(255)      not null
#  certification          :string(255)
#  phone_number           :string(255)
#  email                  :string(255)
#  password               :string(255)
#  is_admin               :boolean          default(FALSE)
#  session_token          :string(255)
#  password_digest        :string(255)
#  admin                  :boolean          default(FALSE)
#  hidden                 :boolean          default(FALSE)
#  active                 :boolean          default(TRUE)
#  hourly_rate            :float(24)
#  can_manage_estimates   :boolean          default(FALSE)
#  role                   :string(255)      default("arborist")
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  crew_member            :boolean          default(TRUE)
#
class ArboristSerializer < ApplicationSerializer
  attribute :name
  attribute :email
  attribute :phone_number
  attribute :role
  attribute :certification
  attribute :hourly_rate
  attribute :current_hourly_rate
end
