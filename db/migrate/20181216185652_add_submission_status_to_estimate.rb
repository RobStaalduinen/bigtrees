class AddSubmissionStatusToEstimate < ActiveRecord::Migration
  def change
    add_column :estimates, :submission_completed, :boolean, default: false
  end
end
