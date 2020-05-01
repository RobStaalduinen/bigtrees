class AddPreferredContactToEstimate < ActiveRecord::Migration
  def change
    add_column :estimates, :preferred_contact, :string
  end
end
