class AddOrganizationToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :estimates, :organization_id, :integer, index: true

    Estimate.update_all(organization_id: 1)
  end
end
