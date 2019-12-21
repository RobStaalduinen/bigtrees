class PopulateInvoices < ActiveRecord::Migration
  def change
    Estimate.all.each do |estimate|
      Invoice.create(
        estimate: estimate,
        number: estimate.invoice_number,
        payment_method: estimate.payment_method,
        paid: estimate.payment_method.present?,
        discount: estimate.discount_applied,
        sent_at: estimate.final_invoice_sent_at
      )
    end
  end
end
