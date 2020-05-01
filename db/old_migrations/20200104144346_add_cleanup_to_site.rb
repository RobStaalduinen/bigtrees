class AddCleanupToSite < ActiveRecord::Migration
  def change
    add_column :sites, :cleanup, :boolean, default: false
  end
end
