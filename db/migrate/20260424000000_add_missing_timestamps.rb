class AddMissingTimestamps < ActiveRecord::Migration[6.0]
  TABLES = %i[appointments extra_costs sites work_actions users site_stats site_config].freeze

  def change
    TABLES.each do |table|
      add_column table, :created_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }, null: false unless column_exists?(table, :created_at)
      add_column table, :updated_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }, null: false unless column_exists?(table, :updated_at)
    end
  end
end
