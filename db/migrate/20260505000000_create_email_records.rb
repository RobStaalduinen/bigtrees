class CreateEmailRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :email_records do |t|
      t.integer :estimate_id, null: false
      t.integer :arborist_id
      t.integer :organization_id
      t.string :template_key, null: false
      t.string :recipient_email
      t.string :nylas_message_id
      t.datetime :sent_at, null: false

      t.timestamps
    end

    add_index :email_records, :estimate_id
    add_index :email_records, :arborist_id
    add_index :email_records, :organization_id
    add_index :email_records, :nylas_message_id
    add_index :email_records, :template_key

    add_foreign_key :email_records, :estimates
    add_foreign_key :email_records, :arborists
    add_foreign_key :email_records, :organizations
  end
end
