class AddPostalCodeToAddress < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :postal_code, :string, index: true
  end
end
