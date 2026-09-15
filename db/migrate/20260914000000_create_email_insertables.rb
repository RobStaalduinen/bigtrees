class CreateEmailInsertables < ActiveRecord::Migration[6.0]
  def change
    create_table :email_insertables do |t|
      t.belongs_to :organization, index: true
      t.string :key, null: false
      t.string :label, null: false

      t.timestamps null: false
    end

    add_index :email_insertables, [:organization_id, :key], unique: true

    create_table :email_insertable_options do |t|
      t.belongs_to :email_insertable, index: true
      t.string :label, null: false
      t.text :content, null: false
      t.integer :position, default: 0, null: false

      t.timestamps null: false
    end
  end
end
