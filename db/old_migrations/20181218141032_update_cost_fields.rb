class UpdateCostFields < ActiveRecord::Migration
  def change
    add_column :trees, :notes, :string

    add_column :estimates, :extra_cost, :decimal
    add_column :estimates, :extra_cost_notes, :string
  end
end
