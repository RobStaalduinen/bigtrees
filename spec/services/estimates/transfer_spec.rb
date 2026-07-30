require 'rails_helper'

RSpec.describe Estimates::Transfer do
  let(:source_org)      { create(:organization, :can_transfer) }
  let(:source_arborist) { create(:arborist, :admin, organization: source_org) }
  let(:target_org)      { create(:organization) }
  let!(:target_arborist) { create(:arborist, :admin, organization: target_org) }
  let(:customer)        { create(:customer) }

  let!(:original) do
    estimate = create(:estimate, :complete,
                      organization: source_org,
                      arborist: source_arborist,
                      customer: customer,
                      quote_sent_date: Date.today,
                      approved: true)
    estimate.costs.create!(description: 'Pruning', amount: 300)
    note = estimate.notes.create!(content: 'Take care with the oak')
    note.create_image!(image_url: 'https://example.com/note.jpg')

    tree = estimate.trees.create!
    tree.tree_images.create!(estimate: estimate, image_url: 'https://example.com/a.jpg',
                             client_upload_id: SecureRandom.uuid)
    # An uncategorized image: attached to the estimate but no tree.
    estimate.tree_images.create!(image_url: 'https://example.com/uncategorized.jpg',
                                 client_upload_id: SecureRandom.uuid)

    # Org-specific associations that must NOT carry over.
    vehicle = Vehicle.create!(name: 'Chipper', organization: source_org)
    estimate.equipment_assignments.create!(vehicle: vehicle)
    tag = Tag.create!(organization: source_org, label: 'Priority', colour: '#fff')
    estimate.taggings.create!(tag: tag)

    estimate
  end

  subject(:transfer) { described_class.call(original.id, target_org.id) }

  it 'creates a new estimate' do
    expect { transfer }.to change(Estimate, :count).by(1)
  end

  it 'returns the new estimate' do
    expect(transfer).to be_a(Estimate)
    expect(transfer.id).not_to eq(original.id)
  end

  describe 'destination org and arborist' do
    it 'places the copy in the target organization' do
      expect(transfer.organization).to eq(target_org)
    end

    it 'assigns the target org default arborist' do
      expect(transfer.arborist).to eq(target_org.default_arborist)
    end
  end

  describe 'provenance link' do
    it 'points the copy back at the original' do
      expect(transfer.transferred_from).to eq(original)
    end

    it 'exposes the copy as the original transferred_to' do
      new_estimate = transfer
      expect(original.reload.transferred_to).to eq(new_estimate)
    end
  end

  describe 'source estimate' do
    it 'marks the original as transferred' do
      transfer
      expect(original.reload.state).to eq('transferred')
    end
  end

  describe 'copied (generic) associations' do
    it 'copies costs' do
      expect(transfer.costs.count).to eq(original.costs.count)
      expect(transfer.costs.map(&:id)).not_to include(*original.costs.map(&:id))
    end

    it 'copies notes and preserves the original author name' do
      expect(transfer.notes.count).to eq(original.notes.count)
      new_note = transfer.notes.find { |n| n.content == 'Take care with the oak' }
      expect(new_note.author_name).to eq(source_arborist.name)
    end

    it 'copies the site' do
      expect(transfer.site).to be_present
      expect(transfer.site.id).not_to eq(original.site.id)
    end

    it 'copies the customer_detail' do
      expect(transfer.customer_detail).to be_present
      expect(transfer.customer_detail.id).not_to eq(original.customer_detail.id)
    end

    it 'keeps the same (global) customer' do
      expect(transfer.customer).to eq(customer)
    end

    it 'copies tree images and clears the unique client_upload_id' do
      expect(transfer.tree_images.count).to eq(original.tree_images.count)
      expect(transfer.tree_images.map(&:client_upload_id)).to all(be_nil)
    end

    it 'copies uncategorized images (tree_id nil)' do
      expect(transfer.tree_images.where(tree_id: nil).count)
        .to eq(original.tree_images.where(tree_id: nil).count)
      expect(transfer.tree_images.where(tree_id: nil)).to be_present
    end

    it 'copies images attached to notes' do
      new_note = transfer.notes.find { |n| n.content == 'Take care with the oak' }
      expect(new_note.image).to be_present
      expect(new_note.image.image_url).to eq('https://example.com/note.jpg')
    end
  end

  describe 'org-specific associations (not copied)' do
    it 'does not copy equipment assignments' do
      expect(transfer.equipment_assignments).to be_empty
    end

    it 'does not copy taggings' do
      expect(transfer.taggings).to be_empty
    end
  end

  describe 'reset fields' do
    it 'clears quote_sent_date and approved' do
      expect(transfer.quote_sent_date).to be_nil
      expect(transfer.approved).to be false
    end
  end

  describe 'guards' do
    it 'raises when the source org may not transfer' do
      source_org.update!(can_transfer: false)
      expect { transfer }.to raise_error(Estimates::Transfer::TransferError)
    end

    it 'raises when the estimate is already transferred' do
      original.update!(state: 'transferred')
      expect { transfer }.to raise_error(Estimates::Transfer::TransferError)
    end

    it 'raises when the target org has no arborist' do
      OrganizationMembership.where(organization: target_org).destroy_all
      expect { transfer }.to raise_error(Estimates::Transfer::TransferError)
    end
  end

  describe 'transaction safety' do
    it 'rolls back on failure without creating a partial estimate or transferring the source' do
      allow_any_instance_of(Cost).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)

      expect { transfer rescue nil }.not_to change(Estimate, :count)
      expect(original.reload.state).to eq('in_progress')
    end
  end
end
