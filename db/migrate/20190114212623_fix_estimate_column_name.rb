class FixEstimateColumnName < ActiveRecord::Migration
  def change
    rename_column :estimates, :arborst_id, :arborist_id
  end
end
