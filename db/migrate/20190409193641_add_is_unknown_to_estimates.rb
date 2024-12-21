class AddIsUnknownToEstimates < ActiveRecord::Migration[5.2]
  def change
    add_column :estimates, :is_unknown, :boolean, index: true, default: false
  end
end
