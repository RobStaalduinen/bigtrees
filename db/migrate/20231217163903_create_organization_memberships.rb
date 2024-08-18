class CreateOrganizationMemberships < ActiveRecord::Migration[5.2]
  def self.up
    create_table :organization_memberships do |t|
      t.belongs_to :organization, index: true
      t.belongs_to :arborist, index: true

      t.timestamps null: false
    end

    Arborist.where.not(organization_id: nil).each do |arborist|
      OrganizationMembership.create(organization_id: arborist.organization_id, arborist_id: arborist.id)
    end
  end

  def self.down
    drop_table :organization_memberships
  end
end
