class AddShortnameToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :short_name, :string, index: true
  end
end
