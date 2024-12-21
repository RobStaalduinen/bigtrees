class AddArboristToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :estimates, :arborst_id, :integer, index: true
  end
end
