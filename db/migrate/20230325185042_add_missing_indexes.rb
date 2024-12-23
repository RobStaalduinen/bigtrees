class AddMissingIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :estimates, :status
    add_index :estimates, :followup_sent_at
    add_index :estimates, :picture_request_sent_at
    add_index :estimates, :is_unknown
    add_index :estimates, :created_at

    add_index :customers, :name
    add_index :customers, :email
    add_index :customers, :phone

    add_index :customer_details, :name
    add_index :customer_details, :email
    add_index :customer_details, :phone

    add_index :sites, :street
    add_index :sites, :city

    add_index :addresses, :street
    add_index :addresses, :city
  end
end
