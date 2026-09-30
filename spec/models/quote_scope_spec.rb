require 'rails_helper'

RSpec.describe QuoteScope, type: :model do
  let(:organization) { create(:organization) }
  let(:estimate) { create(:estimate, organization: organization) }

  describe 'list normalisation' do
    it 'drops blank and whitespace-only entries the editor can submit' do
      scope = described_class.create!(
        estimate: estimate,
        inclusions: ['Stump grinding', '', '   ', 'Brush haul-away'],
        exclusions: ['']
      )

      expect(scope.reload.inclusions).to eq(['Stump grinding', 'Brush haul-away'])
      expect(scope.exclusions).to eq([])
    end

    it 'strips surrounding whitespace from entries and the scope text' do
      scope = described_class.create!(
        estimate: estimate,
        scope_of_work: "  Remove two maples.  ",
        inclusions: ['  Stump grinding  ']
      )

      expect(scope.reload.scope_of_work).to eq('Remove two maples.')
      expect(scope.inclusions).to eq(['Stump grinding'])
    end

    it 'reads nil json columns as empty arrays' do
      scope = described_class.create!(estimate: estimate)

      expect(scope.reload.inclusions).to eq([])
      expect(scope.exclusions).to eq([])
    end
  end

  describe '#any?' do
    it 'is false when nothing is set' do
      expect(described_class.create!(estimate: estimate).any?).to be(false)
    end

    it 'is false when only blank list entries were submitted' do
      scope = described_class.create!(estimate: estimate, inclusions: ['', '  '])

      expect(scope.any?).to be(false)
    end

    it 'is true when the scope text is set' do
      expect(described_class.create!(estimate: estimate, scope_of_work: 'Remove a maple.').any?).to be(true)
    end

    it 'is true when only a list is set' do
      # separate estimate — one quote_scope per estimate
      other = create(:estimate, organization: organization)

      expect(described_class.create!(estimate: other, inclusions: ['Grinding']).any?).to be(true)
    end
  end

  describe 'association' do
    it 'is limited to one per estimate' do
      described_class.create!(estimate: estimate)

      expect { described_class.create!(estimate: estimate) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'is destroyed with the estimate' do
      described_class.create!(estimate: estimate)

      expect { estimate.destroy }.to change(described_class, :count).by(-1)
    end
  end
end
