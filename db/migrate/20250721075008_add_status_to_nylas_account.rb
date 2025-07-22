class AddStatusToNylasAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :nylas_accounts, :status, :string, default: 'active', null: false
  end
end
