class CreateInvoice < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.belongs_to :estimate, index: true
      t.string :number, index: true
      t.string :payment_method
      t.boolean :paid, default: false
      t.boolean :discount, default: false
      t.date :sent_at
    end
  end
end
