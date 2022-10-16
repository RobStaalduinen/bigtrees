class CreateCustomerDetails < ActiveRecord::Migration
  def change
    create_table :customer_details do |t|
      t.belongs_to :estimate

      t.string :name
      t.string :email
      t.string :phone

      t.timestamps null: false
    end
  end
end