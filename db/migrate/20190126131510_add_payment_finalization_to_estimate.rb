class AddPaymentFinalizationToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :estimates, :discount_applied, :boolean, default: false
    add_column :estimates, :payment_method, :string
  end
end
