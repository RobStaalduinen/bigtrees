class UpdateCostFields < ActiveRecord::Migration[5.2]
  def change
    add_column :trees, :notes, :string

    add_column :estimates, :extra_cost, :decimal
    add_column :estimates, :extra_cost_notes, :string
  end
end
