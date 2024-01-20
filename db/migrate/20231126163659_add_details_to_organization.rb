class AddDetailsToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :phone_number, :string
    add_column :organizations, :website, :string
    add_column :organizations, :email, :string

    add_column :organizations, :email_author, :string
    add_column :organizations, :outgoing_quote_email, :string
    add_column :organizations, :quote_bcc, :string
    add_column :organizations, :email_signature, :string

    add_column :organizations, :insurance_provider, :string
    add_column :organizations, :insurance_policy_number, :string
    add_column :organizations, :insurance_description, :string

    add_column :organizations, :hst_number, :string

    add_column :organizations, :address_id, :integer, index: true
  end
end
