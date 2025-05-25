class CreateEquipmentRequest < ActiveRecord::Migration[5.2]
  def change
    create_table :equipment_requests do |t|
      t.belongs_to :arborist
      t.belongs_to :vehicle
      t.date :submitted_at
      t.string :category
      t.text :description
      t.string :state, default: 'submitted'
      # t.attachment :image

      t.timestamps null: false
    end
  end
end
