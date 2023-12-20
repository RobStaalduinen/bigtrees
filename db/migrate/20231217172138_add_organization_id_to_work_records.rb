class AddOrganizationIdToWorkRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :work_records, :organization_id, :integer, index: true

    WorkRecord.update_all(organization_id: Organization.first.id)
  end
end
