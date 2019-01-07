class AddArboristToEstimate < ActiveRecord::Migration
  def change
    add_column :estimates, :arborst_id, :integer, index: true
  end
end
