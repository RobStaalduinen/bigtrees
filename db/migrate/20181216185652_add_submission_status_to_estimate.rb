class AddSubmissionStatusToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :estimates, :submission_completed, :boolean, default: false
  end
end
