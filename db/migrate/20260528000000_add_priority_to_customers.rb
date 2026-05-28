class AddPriorityToCustomers < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :priority, :integer, default: 3, null: false
  end
end
