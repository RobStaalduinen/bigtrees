class CreateExpirations < ActiveRecord::Migration
  def change
    create_table :expirations do |t|
      t.belongs_to :vehicle
      t.string :name
      t.date :date

      t.timestamps null: false
    end
  end
end
