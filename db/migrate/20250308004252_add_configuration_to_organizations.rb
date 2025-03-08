class AddConfigurationToOrganizations < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :configuration, :json
  end
end
