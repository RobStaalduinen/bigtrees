class AddFinalInvoiceSentAtToEstimate < ActiveRecord::Migration
  def change
    add_column :estimates, :final_invoice_sent_at, :date
  end
end
