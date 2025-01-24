class AddTags < ActiveRecord::Migration[6.0]
  def change
    create_table :tags do |t|
      t.belongs_to :organization, index: true
      t.string :label, null: false
      t.string :colour, null: false
      t.boolean :system, default: false

      t.timestamps null: false
    end

    Organization.all.each do |organization|
      Tag.create_default(organization)
    end
  end
end
