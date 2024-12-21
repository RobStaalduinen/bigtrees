class CreateNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :notes do |t|
      t.belongs_to :estimate, index: true
      t.belongs_to :arborist, index: true

      t.string :content

      t.timestamps null: false
    end
  end
end
