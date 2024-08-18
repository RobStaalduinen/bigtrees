class ChangeCostPrecision < ActiveRecord::Migration
  def self.up
    change_column :costs, :amount, :float
  end

  def self.down
    change_column :costs, :amount, :decimal, precision: 10
  end
end
