class AddActiveToArborists < ActiveRecord::Migration
  def change
    add_column :arborists, :active, :boolean, default: true
  end
end
