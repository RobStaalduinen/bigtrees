# frozen_string_literal: true

class WorkRecordSerializer < ApplicationSerializer
  attribute :arborist_id
  attribute :date
  attribute :hours

  attribute :range_string
end
