class AddPhoneAndEmailToArborist < ActiveRecord::Migration[5.2]
  def change
    add_column :arborists, :phone_number, :string
    add_column :arborists, :email, :string
  end
end
