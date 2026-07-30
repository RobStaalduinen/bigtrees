require 'rails_helper'

RSpec.describe Note do
  let(:organization) { create(:organization) }
  let(:arborist)     { create(:arborist, :admin, organization: organization, name: 'Alice') }
  let(:estimate)     { create(:estimate, organization: organization, arborist: arborist) }

  describe 'author_name snapshot' do
    it 'records the author name at creation time' do
      note = estimate.notes.create!(content: 'Hello', author: arborist)
      expect(note.author_name).to eq('Alice')
    end

    it 'defaults the author (and name) to the estimate arborist when none is given' do
      note = estimate.notes.create!(content: 'Hello')
      expect(note.author_name).to eq('Alice')
    end

    it 'stays fixed after the arborist is renamed' do
      note = estimate.notes.create!(content: 'Hello', author: arborist)
      arborist.update!(name: 'Alice Renamed')
      expect(note.reload.author_name).to eq('Alice')
    end

    it 'is not overwritten on subsequent saves' do
      note = estimate.notes.create!(content: 'Hello', author: arborist)
      other = create(:arborist, :admin, organization: organization, name: 'Bob')
      note.update!(author: other)
      expect(note.reload.author_name).to eq('Alice')
    end
  end
end
