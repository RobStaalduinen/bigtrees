class CreateNylasAccount < ActiveRecord::Migration[6.0]
  def change
    create_table :nylas_accounts do |t|
      t.belongs_to :organization, null: false

      t.string :outgoing_email_address
      t.string :code
      t.string :grant_id

      t.json :raw_response

      t.timestamps null: false
    end
  end
end
