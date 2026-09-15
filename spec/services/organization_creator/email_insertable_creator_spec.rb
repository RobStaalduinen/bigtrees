require 'rails_helper'

RSpec.describe OrganizationCreator::EmailInsertableCreator do
  let(:organization) { create(:organization) }
  subject(:creator) { described_class.new(organization) }

  describe '#seed_email_insertables' do
    it 'creates the SCHEDULE_TEXT insertable' do
      expect { creator.seed_email_insertables }.to change(EmailInsertable, :count).by(1)

      insertable = organization.email_insertables.find_by(key: 'SCHEDULE_TEXT')
      expect(insertable.label).to eq('Add Schedule Text')
    end

    it 'creates its five options in order' do
      creator.seed_email_insertables

      insertable = organization.email_insertables.find_by(key: 'SCHEDULE_TEXT')
      expect(insertable.options.map(&:label)).to eq(
        ['Reduced Costs', 'Next few days', 'Within 1 week', 'Within 2 weeks', 'More than 2 weeks']
      )
      expect(insertable.options.map(&:position)).to eq([0, 1, 2, 3, 4])
    end

    it 'does not claim a reserved key' do
      creator.seed_email_insertables

      expect(EmailTemplate::RESERVED_KEYS).not_to include('SCHEDULE_TEXT')
    end

    it 'is idempotent' do
      creator.seed_email_insertables

      expect { creator.seed_email_insertables }.not_to change(EmailInsertable, :count)
      expect { creator.seed_email_insertables }.not_to change(EmailInsertableOption, :count)
    end

    it 'does not overwrite edited option content on re-run' do
      creator.seed_email_insertables
      option = organization.email_insertables.find_by(key: 'SCHEDULE_TEXT').options.find_by(label: 'Next few days')
      option.update!(content: 'Custom scheduling copy.')

      creator.seed_email_insertables

      expect(option.reload.content).to eq('Custom scheduling copy.')
    end

    it 'adds missing options without duplicating existing ones' do
      creator.seed_email_insertables
      insertable = organization.email_insertables.find_by(key: 'SCHEDULE_TEXT')
      insertable.options.find_by(label: 'Within 1 week').destroy

      expect { creator.seed_email_insertables }.to change(EmailInsertableOption, :count).by(1)
      expect(insertable.reload.options.count).to eq(5)
    end
  end
end
