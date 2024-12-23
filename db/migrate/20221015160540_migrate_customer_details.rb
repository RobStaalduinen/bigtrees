class MigrateCustomerDetails < ActiveRecord::Migration[5.2]
  def self.up
    Estimate.joins(:customer).find_each do |e|
      next if e.customer_detail.present?

      CustomerDetail.create(estimate: e, name: e.customer.name, email: e.customer.email, phone: e.customer.phone)
    end
  end

  def self.down
    CustomerDetail.destroy_all
  end
end
