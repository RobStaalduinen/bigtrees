class CreateAddress < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :city
      t.string :postal_code

      t.timestamps null: false
    end

    add_column :customers, :address_id, :integer, index: true
    add_column :sites, :address_id, :integer, index: true
  end
end
