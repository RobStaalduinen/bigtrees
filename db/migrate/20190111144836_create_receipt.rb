class CreateReceipt < ActiveRecord::Migration[5.2]
  def change
    create_table :receipts do |t|
      t.belongs_to :arborist
      t.date :date
      t.string :category
      t.string :job
      t.string :payment_method
      t.string :description
      t.decimal :cost
      # t.attachment :photo
    end
  end
end
