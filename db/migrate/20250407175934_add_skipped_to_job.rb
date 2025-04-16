class AddSkippedToJob < ActiveRecord::Migration[6.0]
  def change
    add_column :jobs, :skipped, :boolean, default: false, null: false
  end
end
