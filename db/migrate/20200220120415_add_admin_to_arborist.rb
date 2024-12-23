class AddAdminToArborist < ActiveRecord::Migration[5.2]
  def change
    add_column :arborists, :admin, :boolean, default: false
    add_column :arborists, :hidden, :boolean, default: false

    Arborist.all.each do |a|
      a.update(admin: a.is_admin)
    end
  end
end
