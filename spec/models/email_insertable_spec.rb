require 'rails_helper'

RSpec.describe EmailInsertable do
  let(:organization) { create(:organization) }

  describe 'key normalization' do
    it 'upcases and strips surrounding brackets and whitespace' do
      insertable = create(:email_insertable, organization: organization, key: '  [schedule_text] ')

      expect(insertable.key).to eq('SCHEDULE_TEXT')
    end
  end

  describe 'validations' do
    it 'is valid with an uppercase underscored key' do
      expect(build(:email_insertable, organization: organization, key: 'SCHEDULE_TEXT')).to be_valid
    end

    it 'requires a key' do
      insertable = build(:email_insertable, organization: organization, key: '')

      expect(insertable).not_to be_valid
      expect(insertable.errors[:key]).to be_present
    end

    it 'requires a label' do
      insertable = build(:email_insertable, organization: organization, label: '')

      expect(insertable).not_to be_valid
      expect(insertable.errors[:label]).to be_present
    end

    it 'rejects a key containing characters outside letters, numbers and underscores' do
      insertable = build(:email_insertable, organization: organization, key: 'SCHEDULE-TEXT')

      expect(insertable).not_to be_valid
      expect(insertable.errors[:key]).to include('must be uppercase letters, numbers and underscores')
    end

    it 'rejects a key starting with a number' do
      insertable = build(:email_insertable, organization: organization, key: '1ST_THING')

      expect(insertable).not_to be_valid
      expect(insertable.errors[:key]).to be_present
    end

    it 'rejects every reserved template key' do
      EmailTemplate::RESERVED_KEYS.each do |reserved|
        insertable = build(:email_insertable, organization: organization, key: reserved)

        expect(insertable).not_to be_valid, "expected #{reserved} to be rejected"
        expect(insertable.errors[:key]).to include('is reserved')
      end
    end

    it 'rejects a reserved key written in brackets or lowercase' do
      insertable = build(:email_insertable, organization: organization, key: '[first_name]')

      expect(insertable).not_to be_valid
      expect(insertable.errors[:key]).to include('is reserved')
    end

    it 'rejects a duplicate key within the same organization' do
      create(:email_insertable, organization: organization, key: 'SCHEDULE_TEXT')
      duplicate = build(:email_insertable, organization: organization, key: 'SCHEDULE_TEXT')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:key]).to be_present
    end

    it 'allows the same key in a different organization' do
      create(:email_insertable, organization: organization, key: 'SCHEDULE_TEXT')
      other = build(:email_insertable, organization: create(:organization), key: 'SCHEDULE_TEXT')

      expect(other).to be_valid
    end
  end

  describe '#placeholder' do
    it 'wraps the key in square brackets' do
      insertable = build(:email_insertable, organization: organization, key: 'SCHEDULE_TEXT')

      expect(insertable.placeholder).to eq('[SCHEDULE_TEXT]')
    end
  end

  describe '#options' do
    let(:insertable) { create(:email_insertable, organization: organization) }

    it 'orders options by position' do
      last = create(:email_insertable_option, email_insertable: insertable, label: 'Last', position: 2)
      first = create(:email_insertable_option, email_insertable: insertable, label: 'First', position: 0)
      middle = create(:email_insertable_option, email_insertable: insertable, label: 'Middle', position: 1)

      expect(insertable.reload.options).to eq([first, middle, last])
    end

    it 'destroys its options when destroyed' do
      create(:email_insertable_option, email_insertable: insertable)

      expect { insertable.destroy }.to change(EmailInsertableOption, :count).by(-1)
    end
  end
end
