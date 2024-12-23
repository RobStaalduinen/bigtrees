class FixEstimateColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :estimates, :arborst_id, :arborist_id
  end
end
