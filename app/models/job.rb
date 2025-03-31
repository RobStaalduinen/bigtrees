# frozen_string_literal: true

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