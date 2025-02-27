class CreatePayout < ActiveRecord::Migration[5.2]
  def change
    create_table :payouts do |t|
      t.date :date

      t.timestamps null: false
    end

    add_column :work_records, :payout_id, :integer, index: true, foreign_key: true
  end
end
