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
class Job < ActiveRecord::Base
  belongs_to :estimate
  belongs_to :arborist

  has_many :job_assignments
  has_many :assigned_arborists, through: :job_assignments, source: :arborist

  def started?
    self.started_at.present?
  end

  def completed?
    self.completed_at.present?
  end

  def lead_arborist_name
    self.arborist&.name
  end

  def assigned_arborist_names
    self.assigned_arborists.map(&:name)
  end
end
