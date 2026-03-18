# frozen_string_literal: true

# == Schema Information
#
# Table name: jobs
#
#  id                          :bigint           not null, primary key
#  estimate_id                 :bigint           not null
#  started_at                  :datetime
#  completed_at                :datetime
#  job_survey_responses        :json
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  arborist_id                 :integer
#  skipped                     :boolean          default(FALSE), not null
#  completion_survey_responses :json
#  completion_notes            :text(65535)
#  followup_year               :integer
#
class JobSerializer < ApplicationSerializer
  attribute :started_at
  attribute :completed_at
  attribute :job_survey_responses
  attribute :completion_survey_responses
  attribute :completion_notes
  attribute :followup_year
  attribute :arborist_id
  attribute :lead_arborist_name
  attribute :assigned_arborist_names
  attribute :assigned_arborist_ids
  attribute :skipped
end
