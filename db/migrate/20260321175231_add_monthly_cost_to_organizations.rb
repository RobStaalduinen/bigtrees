class AddMonthlyCostToOrganizations < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :monthly_cost, :float, default: 0.0
  end
end
