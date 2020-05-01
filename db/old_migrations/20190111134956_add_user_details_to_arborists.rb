class AddUserDetailsToArborists < ActiveRecord::Migration
  def change
    add_column :arborists, :password, :string
    add_column :arborists, :is_admin, :boolean, default: false
    add_column :arborists, :session_token, :string
  end
end
