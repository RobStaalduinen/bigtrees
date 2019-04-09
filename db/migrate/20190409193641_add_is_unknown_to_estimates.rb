class AddIsUnknownToEstimates < ActiveRecord::Migration
  def change
    add_column :estimates, :is_unknown, :boolean, index: true, default: false
  end
end
