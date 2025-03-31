# frozen_string_literal: true

class JobAssignment < ActiveRecord::Base
  belongs_to :job
  belongs_to :arborist
end