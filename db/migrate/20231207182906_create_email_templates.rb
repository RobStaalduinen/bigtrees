class CreateEmailTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :email_templates do |t|
      t.belongs_to :organization
      t.string :key, index: true
      t.string :subject
      t.text :content

      t.timestamps null: false
    end
  end
end
