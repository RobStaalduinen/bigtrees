class CreateOrganization < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name

      t.timestamps null: false
    end

    add_column :arborists, :organization_id, :integer, index: true

    o = Organization.create(name: 'Big Tree Services')

    Arborist.update_all(organization_id: o.id)
  end
end
