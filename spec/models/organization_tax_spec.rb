require 'rails_helper'

RSpec.describe 'Organization sales tax', type: :model do
  let(:organization) { create(:organization) }

  describe 'defaults' do
    # These reproduce the hardcoded 13% HST every organization was billed at
    # before the columns existed; changing them changes existing money.
    it 'is HST at 13%' do
      expect(organization.tax_description).to eq('HST')
      expect(organization.tax_rate).to eq(13)
      expect(organization.tax_multiplier).to eq(0.13)
    end
  end

  describe '#tax_multiplier' do
    it 'converts the whole-number percentage' do
      expect(create(:organization, tax_rate: 5).tax_multiplier).to eq(0.05)
      expect(create(:organization, tax_rate: 0).tax_multiplier).to eq(0.0)
      expect(create(:organization, tax_rate: 100).tax_multiplier).to eq(1.0)
    end
  end

  describe 'validation' do
    it 'rejects a rate outside 0-100' do
      expect(build(:organization, tax_rate: -1)).not_to be_valid
      expect(build(:organization, tax_rate: 101)).not_to be_valid
    end

    it 'rejects a fractional rate — the column is a whole percentage' do
      expect(build(:organization, tax_rate: 12.5)).not_to be_valid
    end

    it 'requires a description' do
      expect(build(:organization, tax_description: '')).not_to be_valid
    end
  end

  describe 'Estimate totals' do
    let(:estimate) { create(:estimate, organization: organization) }

    before { estimate.costs.create!(description: 'Work', amount: 100.0) }

    it 'uses the organization rate' do
      expect(estimate.reload.tax_amount).to eq(13.0)
      expect(estimate.total_cost_with_tax).to eq(113.0)
    end

    it 'follows a change of rate' do
      organization.update!(tax_description: 'GST', tax_rate: 5)

      expect(estimate.reload.tax_amount).to eq(5.0)
      expect(estimate.total_cost_with_tax).to eq(105.0)
      expect(estimate.tax_description).to eq('GST')
    end

    it 'charges nothing at 0% and leaves the total equal to the subtotal' do
      organization.update!(tax_rate: 0)

      expect(estimate.reload.tax_amount).to eq(0.0)
      expect(estimate.total_cost_with_tax).to eq(estimate.total_cost)
    end

    it 'labels the tax with its name and rate' do
      expect(estimate.tax_label).to eq('HST (13%)')

      organization.update!(tax_description: 'GST + PST', tax_rate: 12)
      expect(estimate.reload.tax_label).to eq('GST + PST (12%)')
    end

    # The serializer still exposes `hst`, so the alias has to keep working.
    it 'keeps #hst as an alias of #tax_amount' do
      expect(estimate.reload.hst).to eq(estimate.tax_amount)
    end
  end
end
