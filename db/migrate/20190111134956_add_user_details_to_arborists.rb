class AddUserDetailsToArborists < ActiveRecord::Migration[5.2]
  def change
    add_column :arborists, :password, :string
    add_column :arborists, :is_admin, :boolean, default: false
    add_column :arborists, :session_token, :string
  end
end
