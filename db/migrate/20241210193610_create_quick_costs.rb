# frozen_string_literal: true

class CreateQuickCosts < ActiveRecord::Migration[5.2]
  def change
    create_table :quick_costs do |t|
      t.belongs_to :organization
      t.string :label
      t.string :content
      t.decimal :default_cost, precision: 8, scale: 2, default: 0.0

      t.timestamps null: false
    end
  end
end
