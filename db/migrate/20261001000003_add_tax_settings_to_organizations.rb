class AddTaxSettingsToOrganizations < ActiveRecord::Migration[8.0]
  # Per-organization sales tax. Defaults reproduce the hardcoded 13% HST every
  # existing organization was billed at, so no quote total changes on deploy.
  #
  # tax_rate is a whole-number percentage (13, not 0.13) because that is how
  # people enter and talk about it; Organization#tax_multiplier converts.
  def change
    add_column :organizations, :tax_description, :string,  null: false, default: 'HST'
    add_column :organizations, :tax_rate,        :integer, null: false, default: 13
  end
end
