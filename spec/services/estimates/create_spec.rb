require 'rails_helper'

RSpec.describe Estimates::Create do
  let(:organization) { create(:organization) }
  let(:arborist)     { create(:arborist, :admin, organization: organization) }
  let(:customer)     { create(:customer) }

  let(:base_params) do
    { tree_quantity: 2, is_unknown: false }
  end

  # A minimal Customer policy scope stub that wraps the real relation
  def customer_scope
    Customer.all
  end

  def call_service(overrides = {})
    described_class.call(**{
      estimate_params:        ActionController::Parameters.new(base_params).permit!,
      org:                    organization,
      current_user:           arborist,
      policy_scope:           customer_scope
    }.merge(overrides))
  end

  describe 'estimate creation' do
    it 'creates a new estimate' do
      expect { call_service }.to change(Estimate, :count).by(1)
    end

    it 'assigns the current organization' do
      estimate = call_service
      expect(estimate.organization).to eq(organization)
    end

    it 'assigns current_user as arborist when they belong to the org' do
      estimate = call_service
      expect(estimate.arborist).to eq(arborist)
    end

    it 'assigns the org default arborist when current user does not belong to the org' do
      other_arborist = create(:arborist, :admin)
      estimate = call_service(current_user: other_arborist)
      expect(estimate.arborist).to eq(organization.default_arborist)
    end
  end

  describe 'site creation' do
    it 'creates a site when site_params are provided' do
      site_params = ActionController::Parameters.new(wood_removal: true).permit!
      expect {
        call_service(site_params: site_params)
      }.to change(Site, :count).by(1)
    end

    it 'does not create a site when site_params are omitted' do
      expect { call_service }.not_to change(Site, :count)
    end
  end

  describe 'customer handling' do
    context 'when customer params include an existing customer id' do
      before do
        # Ensure customer is in the scope (customer_scope returns Customer.all)
      end

      it 'associates the existing customer with the estimate' do
        customer_params = ActionController::Parameters.new(
          id: customer.id, name: customer.name, email: customer.email
        ).permit!
        customer_detail_params = ActionController::Parameters.new(
          name: customer.name, email: customer.email
        ).permit!

        estimate = call_service(
          customer_params: customer_params,
          customer_detail_params: customer_detail_params
        )
        expect(estimate.customer).to eq(customer)
      end
    end

    context 'when no customer id is given (new customer)' do
      it 'creates a new customer' do
        customer_params = ActionController::Parameters.new(
          name: 'Jane Doe', email: 'jane@example.com', phone: '555-0000'
        ).permit!
        customer_detail_params = ActionController::Parameters.new(
          name: 'Jane Doe', email: 'jane@example.com'
        ).permit!

        expect {
          call_service(
            customer_params: customer_params,
            customer_detail_params: customer_detail_params
          )
        }.to change(Customer, :count).by(1)
      end
    end

    it 'creates a customer_detail when customer params are provided' do
      customer_params = ActionController::Parameters.new(
        name: 'Jane Doe', email: 'jane@example.com'
      ).permit!
      customer_detail_params = ActionController::Parameters.new(
        name: 'Jane Doe', email: 'jane@example.com'
      ).permit!

      expect {
        call_service(
          customer_params: customer_params,
          customer_detail_params: customer_detail_params
        )
      }.to change(CustomerDetail, :count).by(1)
    end

    it 'does not create a customer when customer_params are omitted' do
      expect { call_service }.not_to change(Customer, :count)
    end
  end

  describe 'job creation' do
    it 'creates a job when job_attributes are provided' do
      job_attrs = ActionController::Parameters.new(
        started_at: nil, completion_notes: 'Test job'
      ).permit!

      expect {
        call_service(job_attributes: job_attrs)
      }.to change(Job, :count).by(1)
    end

    it 'does not create a job when job_attributes are omitted' do
      expect { call_service }.not_to change(Job, :count)
    end
  end
end
