class AddActiveToArborists < ActiveRecord::Migration[5.2]
  def change
    add_column :arborists, :active, :boolean, default: true
  end
end
