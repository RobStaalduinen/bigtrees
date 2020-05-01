class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.belongs_to :arborist, index: true
      t.string :name
      t.attachment :file

      t.timestamps null: false
    end
  end
end
