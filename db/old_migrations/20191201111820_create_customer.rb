class CreateCustomer < ActiveRecord::Migration
  def change
    if Rails.env.test?
      create_table :customers do |t|
        t.string :name
        t.string :email
        t.string :phone
        t.string :preferred_contact
      end
    end

    add_column :estimates, :customer_id, :integer, index: true
  end
end
