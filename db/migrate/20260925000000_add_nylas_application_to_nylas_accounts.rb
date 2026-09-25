class AddNylasApplicationToNylasAccounts < ActiveRecord::Migration[8.0]
  def up
    add_column :nylas_accounts, :nylas_application, :string, default: 'production', null: false

    # Every grant that exists at this point was created under the sandbox
    # application — the production app did not exist yet.
    NylasAccount.reset_column_information
    NylasAccount.update_all(nylas_application: 'sandbox')
  end

  def down
    remove_column :nylas_accounts, :nylas_application
  end
end
