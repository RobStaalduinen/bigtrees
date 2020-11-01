class AddLowAccessWidthToSite < ActiveRecord::Migration
  def change
    add_column :sites, :low_access_width, :boolean, default: false
  end
end
