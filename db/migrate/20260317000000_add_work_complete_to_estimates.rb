class AddWorkCompleteToEstimates < ActiveRecord::Migration[6.0]
  def change
    add_column :estimates, :work_complete, :boolean, default: false, null: false
  end
end
