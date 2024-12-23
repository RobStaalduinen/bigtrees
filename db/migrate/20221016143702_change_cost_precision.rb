class ChangeCostPrecision < ActiveRecord::Migration[5.2]
  def self.up
    change_column :costs, :amount, :float
  end

  def self.down
    change_column :costs, :amount, :decimal, precision: 10
  end
end
