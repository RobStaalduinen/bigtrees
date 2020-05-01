class RemoveCustomerColumnsFromEstimate < ActiveRecord::Migration
  def change
    remove_column :estimates, :person_name
    remove_column :estimates, :email
    remove_column :estimates, :phone
    remove_column :estimates, :preferred_contact
  end
end
