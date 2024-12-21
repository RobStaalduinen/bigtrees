class PopulateCustomers < ActiveRecord::Migration[5.2]
  def change
    Estimate.submitted.each do |estimate|
      customer = Customer.where(name: estimate.person_name).last

      customer ||= Customer.create(
          name: estimate.person_name,
          email: estimate.email,
          phone: estimate.phone,
          preferred_contact: estimate.preferred_contact
        )

      estimate.update(customer_id: customer.id)
    end
  end

end
