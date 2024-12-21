class CreateCosts < ActiveRecord::Migration[5.2]
  def change
    create_table :costs do |t|
      t.belongs_to :estimate
      t.decimal :amount
      t.string :description
      t.boolean :discount, default: false
    end
  end
end
