class AddAndUpdateApprovedStatus < ActiveRecord::Migration[6.0]
  def change
    add_column :estimates, :approved, :boolean, default: false

    Estimate.where("status >= 5").update_all(approved: true)
  end
end
