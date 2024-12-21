class AddPreferredContactToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :estimates, :preferred_contact, :string
  end
end
