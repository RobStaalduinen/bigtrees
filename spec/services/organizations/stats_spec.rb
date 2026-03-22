require 'rails_helper'

RSpec.describe Organizations::Stats do
  let(:organization) { create(:organization) }
  let(:other_org)    { create(:organization) }
  let(:arborist)     { create(:arborist, :admin, organization: organization) }

  subject(:result) { described_class.call(Organization.where(id: organization.id)) }
  subject(:stats)  { result.first }

  describe 'structure' do
    it 'returns one entry per organization' do
      expect(result.length).to eq(1)
    end

    it 'includes the organization id' do
      expect(stats[:id]).to eq(organization.id)
    end

    it 'includes estimates, invoices, receipts and work_records keys' do
      expect(stats.keys).to contain_exactly(:id, :estimates, :invoices, :receipts, :work_records)
    end

    it 'each metric has total and recent keys' do
      [:estimates, :invoices, :receipts, :work_records].each do |metric|
        expect(stats[metric].keys).to contain_exactly(:total, :recent)
      end
    end
  end

  describe 'estimates' do
    let!(:old_estimate)    { create(:estimate, organization: organization, arborist: arborist, created_at: 20.days.ago) }
    let!(:recent_estimate) { create(:estimate, organization: organization, arborist: arborist, created_at: 5.days.ago) }
    let!(:other_estimate)  { create(:estimate, organization: other_org, arborist: arborist, created_at: 1.day.ago) }

    it 'counts all estimates for the organization' do
      expect(stats[:estimates][:total]).to eq(2)
    end

    it 'counts only estimates within 14 days' do
      expect(stats[:estimates][:recent]).to eq(1)
    end
  end

  describe 'invoices' do
    let(:estimate)        { create(:estimate, organization: organization, arborist: arborist) }
    let(:other_estimate)  { create(:estimate, organization: other_org, arborist: arborist) }
    let!(:old_invoice)    { create(:invoice, estimate: estimate, created_at: 20.days.ago) }
    let!(:recent_invoice) { create(:invoice, estimate: estimate, created_at: 5.days.ago) }
    let!(:other_invoice)  { create(:invoice, estimate: other_estimate, created_at: 1.day.ago) }

    it 'counts all invoices for the organization' do
      expect(stats[:invoices][:total]).to eq(2)
    end

    it 'counts only invoices within 14 days' do
      expect(stats[:invoices][:recent]).to eq(1)
    end
  end

  describe 'receipts' do
    let!(:old_receipt)    { create(:receipt, organization: organization, arborist: arborist, created_at: 20.days.ago) }
    let!(:recent_receipt) { create(:receipt, organization: organization, arborist: arborist, created_at: 5.days.ago) }
    let!(:other_receipt)  { create(:receipt, organization: other_org, arborist: arborist, created_at: 1.day.ago) }

    it 'counts all receipts for the organization' do
      expect(stats[:receipts][:total]).to eq(2)
    end

    it 'counts only receipts within 14 days' do
      expect(stats[:receipts][:recent]).to eq(1)
    end
  end

  describe 'work_records' do
    before { allow(OrganizationContext).to receive(:current_organization).and_return(organization) }

    let!(:old_record)    { create(:work_record, organization: organization, arborist: arborist, created_at: 20.days.ago) }
    let!(:recent_record) { create(:work_record, organization: organization, arborist: arborist, created_at: 5.days.ago) }
    let!(:other_record)  { create(:work_record, organization: other_org, arborist: arborist, created_at: 1.day.ago) }

    it 'counts all work records for the organization' do
      expect(stats[:work_records][:total]).to eq(2)
    end

    it 'counts only work records within 14 days' do
      expect(stats[:work_records][:recent]).to eq(1)
    end
  end

  describe 'multiple organizations' do
    let(:org_a) { create(:organization) }
    let(:org_b) { create(:organization) }
    let(:arborist_a) { create(:arborist, :admin, organization: org_a) }
    let(:arborist_b) { create(:arborist, :admin, organization: org_b) }

    before do
      create(:estimate, organization: org_a, arborist: arborist_a)
      create(:estimate, organization: org_a, arborist: arborist_a)
      create(:estimate, organization: org_b, arborist: arborist_b)
    end

    subject(:multi_result) { described_class.call(Organization.where(id: [org_a.id, org_b.id])) }

    it 'returns an entry for each organization' do
      expect(multi_result.length).to eq(2)
    end

    it 'does not mix counts across organizations' do
      entry_a = multi_result.find { |e| e[:id] == org_a.id }
      entry_b = multi_result.find { |e| e[:id] == org_b.id }
      expect(entry_a[:estimates][:total]).to eq(2)
      expect(entry_b[:estimates][:total]).to eq(1)
    end
  end
end
