class CreateCustomer < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :preferred_contact
    end

    add_column :estimates, :customer_id, :integer, index: true
  end
end
