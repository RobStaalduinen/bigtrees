class CreateImage < ActiveRecord::Migration[5.2]
  def change
    create_table :images do |t|
      t.belongs_to :imageable, polymorphic: true
      t.string :image_url
      t.string :edited_image_url

      t.timestamps null: false
    end
  end
end
