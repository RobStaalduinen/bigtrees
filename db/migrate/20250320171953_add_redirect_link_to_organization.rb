class AddRedirectLinkToOrganization < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :quote_redirect_link, :string
  end
end
