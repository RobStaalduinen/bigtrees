class RemoveCustomerColumnsFromEstimate < ActiveRecord::Migration[5.2]
  def change
    remove_column :estimates, :person_name
    remove_column :estimates, :email
    remove_column :estimates, :phone
    remove_column :estimates, :preferred_contact
  end
end
