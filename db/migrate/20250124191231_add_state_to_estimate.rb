class AddStateToEstimate < ActiveRecord::Migration[6.0]
  def change
    add_column :estimates, :state, :string, default: 'in_progress', null: false, index: true
    add_column :estimates, :state_reason, :string, null: true
  end
end
