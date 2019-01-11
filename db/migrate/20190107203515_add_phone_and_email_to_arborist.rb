class AddPhoneAndEmailToArborist < ActiveRecord::Migration
  def change
    add_column :arborists, :phone_number, :string
    add_column :arborists, :email, :string
  end
end
