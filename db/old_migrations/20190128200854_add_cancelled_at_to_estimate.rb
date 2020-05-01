class AddCancelledAtToEstimate < ActiveRecord::Migration
  def change
    add_column :estimates, :cancelled_at, :date
  end
end
