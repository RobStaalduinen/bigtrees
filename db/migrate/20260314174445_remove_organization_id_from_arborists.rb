class RemoveOrganizationIdFromArborists < ActiveRecord::Migration[6.0]
  def change
    remove_column :arborists, :organization_id, :integer
  end
end
