class AddCancelledAtToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :estimates, :cancelled_at, :date
  end
end
