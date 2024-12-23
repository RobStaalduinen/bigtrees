class AddCleanupToSite < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :cleanup, :boolean, default: false
  end
end
