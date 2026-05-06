require 'rails_helper'

RSpec.describe EmailRecord, type: :model do
  let(:organization) { create(:organization) }
  let(:arborist)     { create(:arborist, :admin, organization: organization) }
  let(:customer)     { create(:customer) }
  let(:estimate)     { create(:estimate, organization: organization, arborist: arborist, customer: customer) }

  it 'is valid with the required attributes' do
    record = build(:email_record, estimate: estimate, arborist: arborist, organization: organization)
    expect(record).to be_valid
  end

  it 'requires a template_key' do
    record = build(:email_record, estimate: estimate, template_key: nil)
    expect(record).not_to be_valid
    expect(record.errors[:template_key]).to be_present
  end

  it 'requires a sent_at' do
    record = build(:email_record, estimate: estimate, sent_at: nil)
    expect(record).not_to be_valid
    expect(record.errors[:sent_at]).to be_present
  end

  it 'allows arborist and organization to be optional' do
    record = build(:email_record, estimate: estimate, arborist: nil, organization: nil)
    expect(record).to be_valid
  end

  describe 'estimate association' do
    it 'is destroyed when the estimate is destroyed' do
      record = create(:email_record, estimate: estimate, arborist: arborist, organization: organization)
      expect { estimate.destroy }.to change { EmailRecord.where(id: record.id).count }.from(1).to(0)
    end
  end

  describe Nylas::Wrapper do
    describe '.extract_message_id' do
      it 'returns nil for nil input' do
        expect(Nylas::Wrapper.extract_message_id(nil)).to be_nil
      end

      it 'returns the id from a Nylas SDK [data, request_id] tuple with symbol keys' do
        response = [{ id: 'abc123', grant_id: 'g' }, 'req-1']
        expect(Nylas::Wrapper.extract_message_id(response)).to eq('abc123')
      end

      it 'returns the id from a multipart JSON response with a wrapping data key' do
        response = { 'request_id' => 'req-1', 'data' => { 'id' => 'def456' } }
        expect(Nylas::Wrapper.extract_message_id(response)).to eq('def456')
      end

      it 'returns the id when the hash has the id at the top level with string keys' do
        response = { 'id' => 'ghi789' }
        expect(Nylas::Wrapper.extract_message_id(response)).to eq('ghi789')
      end
    end
  end
end
