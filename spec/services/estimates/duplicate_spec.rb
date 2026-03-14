require 'rails_helper'

RSpec.describe Estimates::Duplicate do
  let(:organization) { create(:organization) }
  let(:arborist)     { create(:arborist, :admin, organization: organization) }
  let(:customer)     { create(:customer) }

  let!(:original) do
    estimate = create(:estimate, :complete,
                      organization: organization,
                      arborist: arborist,
                      customer: customer,
                      quote_sent_date: Date.today,
                      work_start_date: Date.today,
                      work_end_date: Date.today,
                      approved: true)
    estimate.costs.create!(description: 'Pruning', amount: 300)
    estimate.notes.create!(content: 'Take care with the oak')
    estimate
  end

  subject(:duplicate) { described_class.call(original.id) }

  it 'creates a new estimate' do
    expect { duplicate }.to change(Estimate, :count).by(1)
  end

  it 'returns the new estimate' do
    expect(duplicate).to be_a(Estimate)
    expect(duplicate.id).not_to eq(original.id)
  end

  describe 'reset fields' do
    it 'resets status (second save recalculates from associations)' do
      # The service sets status = :needs_costs before copying associations, then
      # re-saves after duplication so set_status recalculates. With costs+arborist
      # and no quote_sent_date, the resulting status is pending_quote.
      expect(duplicate.status).to eq('pending_quote')
    end

    it 'clears quote_sent_date' do
      expect(duplicate.quote_sent_date).to be_nil
    end

    it 'clears work_start_date' do
      expect(duplicate.work_start_date).to be_nil
    end

    it 'clears work_end_date' do
      expect(duplicate.work_end_date).to be_nil
    end

    it 'clears cancelled_at' do
      expect(duplicate.cancelled_at).to be_nil
    end

    it 'sets approved to false' do
      expect(duplicate.approved).to be false
    end

    it 'sets submission_completed to true' do
      expect(duplicate.submission_completed).to be true
    end
  end

  describe 'duplicated associations' do
    it 'duplicates costs' do
      expect(duplicate.costs.count).to eq(original.costs.count)
    end

    it 'duplicates notes' do
      expect(duplicate.notes.count).to eq(original.notes.count)
    end

    it 'duplicates the site' do
      expect(duplicate.site).to be_present
      expect(duplicate.site.id).not_to eq(original.site.id)
    end

    it 'duplicates the customer_detail' do
      expect(duplicate.customer_detail).to be_present
      expect(duplicate.customer_detail.id).not_to eq(original.customer_detail.id)
    end

    it 'does not share records with the original' do
      expect(duplicate.costs.map(&:id)).not_to include(*original.costs.map(&:id))
    end
  end

  describe 'transaction safety' do
    it 'rolls back on failure and does not create a partial estimate' do
      allow_any_instance_of(Cost).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)

      expect { duplicate rescue nil }.not_to change(Estimate, :count)
    end
  end
end
