class AddCondensedLogoToOrganization < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :condensed_logo_url, :string
  end
end
