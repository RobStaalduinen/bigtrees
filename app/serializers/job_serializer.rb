# frozen_string_literal: true

class JobSerializer < ApplicationSerializer
  attribute :started_at
  attribute :completed_at
  attribute :job_survey_responses
  attribute :lead_arborist_name
  attribute :assigned_arborist_names
  attribute :skipped
end
