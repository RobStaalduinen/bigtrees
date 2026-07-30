class AddTransferredFromToEstimates < ActiveRecord::Migration[8.0]
  def change
    add_column :estimates, :transferred_from_estimate_id, :integer
    add_index :estimates, :transferred_from_estimate_id
  end
end
