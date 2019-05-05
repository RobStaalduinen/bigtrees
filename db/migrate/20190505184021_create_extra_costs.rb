class CreateExtraCosts < ActiveRecord::Migration
  def change
    create_table :extra_costs do |t|
      t.belongs_to :estimate, index: true
      t.decimal :amount
      t.string :description
    end
  end
end
