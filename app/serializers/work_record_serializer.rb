# frozen_string_literal: true

# == Schema Information
#
# Table name: work_records
#
#  id              :integer          not null, primary key
#  arborist_id     :integer
#  date            :date
#  hours           :float(24)
#  start_at        :time
#  end_at          :time
#  unpaid_hours    :float(24)
#  hourly_rate     :float(24)
#  payout_id       :integer
#  organization_id :integer
#
class WorkRecordSerializer < ApplicationSerializer
  attribute :arborist_id
  attribute :date
  attribute :hours

  attribute :range_string
end
