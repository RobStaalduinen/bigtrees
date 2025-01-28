class AddStateToEstimate < ActiveRecord::Migration[6.0]
  def change
    add_column :estimates, :state, :string, default: 'in_progress', null: false, index: true

    Estimate.pending_permit.update_all(state: 'on_hold')
    Estimate.where(is_unknown: true).update_all(state: 'unknown')
    Estimate.completed.update_all(state: 'done')
  end
end
