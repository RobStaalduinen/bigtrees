class AddRoleToArborist < ActiveRecord::Migration
  def change
    add_column :arborists, :role, :string, default: 'arborist'
  end
end
