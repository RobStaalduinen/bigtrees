require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe '#formatted_address' do
    context 'when the customer has a full address' do
      it 'returns street, city, and postal_code joined by commas' do
        customer = create(:customer)
        create(:address, addressable: customer, street: '123 Main St', city: 'Toronto', postal_code: 'M4C 1A1')
        customer.reload

        expect(customer.formatted_address).to eq('123 Main St, Toronto, M4C 1A1')
      end
    end

    context 'when postal_code is blank' do
      it 'omits the blank field' do
        customer = create(:customer)
        create(:address, addressable: customer, street: '123 Main St', city: 'Toronto', postal_code: '')
        customer.reload

        expect(customer.formatted_address).to eq('123 Main St, Toronto')
      end
    end

    context 'when postal_code is nil' do
      it 'omits the nil field' do
        customer = create(:customer)
        create(:address, addressable: customer, street: '123 Main St', city: 'Toronto', postal_code: nil)
        customer.reload

        expect(customer.formatted_address).to eq('123 Main St, Toronto')
      end
    end

    context 'when the customer has no address' do
      it 'returns nil' do
        customer = create(:customer)

        expect(customer.formatted_address).to be_nil
      end
    end
  end

  describe '#last_estimate_status' do
    context 'when the customer has estimates' do
      it 'returns the formatted_status of the most recent estimate' do
        customer = create(:customer)
        create(:estimate, customer: customer)
        last_estimate = create(:estimate, customer: customer)

        expect(customer.last_estimate_status).to eq(last_estimate.formatted_status)
      end

      it 'uses the estimate with the highest id' do
        customer = create(:customer)
        create(:estimate, customer: customer)
        most_recent = create(:estimate, customer: customer)

        expect(customer.last_estimate_status).to eq(most_recent.formatted_status)
      end
    end

    context 'when the customer has no estimates' do
      it 'returns nil' do
        customer = create(:customer)

        expect(customer.last_estimate_status).to be_nil
      end
    end
  end

  describe '#last_activity_date' do
    context 'when the customer has estimates' do
      it 'returns the created_at date of the most recent estimate' do
        customer = create(:customer)
        create(:estimate, customer: customer)
        most_recent = create(:estimate, customer: customer)

        expect(customer.last_activity_date).to eq(most_recent.created_at.to_date)
      end
    end

    context 'when the customer has no estimates' do
      it 'returns nil' do
        customer = create(:customer)

        expect(customer.last_activity_date).to be_nil
      end
    end
  end
end
