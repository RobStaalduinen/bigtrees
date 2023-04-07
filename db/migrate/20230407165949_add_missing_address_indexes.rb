class AddMissingAddressIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :addresses, :addressable_id
    add_index :addresses, :addressable_type
  end
end
