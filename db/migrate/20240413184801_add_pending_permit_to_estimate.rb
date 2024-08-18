class AddPendingPermitToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :estimates, :pending_permit, :boolean, default: false, index: true
  end
end
