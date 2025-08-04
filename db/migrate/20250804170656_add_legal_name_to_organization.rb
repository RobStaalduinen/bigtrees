class AddLegalNameToOrganization < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :legal_name, :string, null: true, default: nil
  end
end
