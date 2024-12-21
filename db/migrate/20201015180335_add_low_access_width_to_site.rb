class AddLowAccessWidthToSite < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :low_access_width, :boolean, default: false
  end
end
