# frozen_string_literal: true

# == Schema Information
#
# Table name: job_assignments
#
#  id          :bigint           not null, primary key
#  job_id      :bigint           not null
#  arborist_id :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class JobAssignment < ActiveRecord::Base
  belongs_to :job
  belongs_to :arborist
end
