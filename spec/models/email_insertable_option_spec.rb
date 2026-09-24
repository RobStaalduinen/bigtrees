require 'rails_helper'

RSpec.describe EmailInsertableOption do
  let(:insertable) { create(:email_insertable) }

  describe 'validations' do
    it 'requires a label' do
      option = build(:email_insertable_option, email_insertable: insertable, label: '')

      expect(option).not_to be_valid
      expect(option.errors[:label]).to be_present
    end

    it 'requires content' do
      option = build(:email_insertable_option, email_insertable: insertable, content: '')

      expect(option).not_to be_valid
      expect(option.errors[:content]).to be_present
    end
  end

  describe 'content formatting' do
    it 'round-trips leading whitespace, trailing whitespace and embedded newlines' do
      raw = "  First paragraph.\n\nSecond paragraph.\n\tIndented line.  \n"
      option = create(:email_insertable_option, email_insertable: insertable, content: raw)

      expect(option.reload.content).to eq(raw)
    end
  end
end
