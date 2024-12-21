class AddRoleToArborist < ActiveRecord::Migration[5.2]
  def change
    add_column :arborists, :role, :string, default: 'arborist'
  end
end
