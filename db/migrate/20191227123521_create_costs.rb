class CreateCosts < ActiveRecord::Migration
  def change
    create_table :costs do |t|
      t.belongs_to :estimate
      t.decimal :amount
      t.string :description
      t.boolean :discount, default: false
    end
  end
end
