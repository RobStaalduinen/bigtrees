class AddTimestampsToKeyModels < ActiveRecord::Migration[6.0]
  TABLES = %i[work_records tree_images invoices receipts trees vehicles customers costs arborists].freeze

  def change
    TABLES.each do |table|
      add_column table, :created_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }, null: false
      add_column table, :updated_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end
  end
end
