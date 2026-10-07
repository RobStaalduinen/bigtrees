require 'rails_helper'

RSpec.describe EquipmentRequest, type: :model do
  let(:organization) { create(:organization) }
  let(:arborist) { create(:arborist, organization: organization) }

  def build_request(attrs = {})
    EquipmentRequest.new({
      organization: organization,
      arborist: arborist,
      category: 'mechanical',
      description: 'Chipper belt is slipping'
    }.merge(attrs))
  end

  describe '#image_urls=' do
    it 'stores every image in the given order' do
      request = build_request(image_urls: ['https://s3/a.jpg', 'https://s3/b.jpg'])
      request.save!

      expect(request.reload.image_urls).to eq(['https://s3/a.jpg', 'https://s3/b.jpg'])
      expect(request.images.map(&:position)).to eq([0, 1])
    end

    it 'ignores blanks and duplicates' do
      request = build_request(image_urls: ['https://s3/a.jpg', '', nil, 'https://s3/a.jpg'])
      request.save!

      expect(request.reload.image_urls).to eq(['https://s3/a.jpg'])
    end

    it 'replaces the image set on update, keeping images that remain' do
      request = build_request(image_urls: ['https://s3/a.jpg', 'https://s3/b.jpg'])
      request.save!
      kept_id = request.images.find_by(image_url: 'https://s3/b.jpg').id

      request.update!(image_urls: ['https://s3/b.jpg', 'https://s3/c.jpg'])

      request.reload
      expect(request.image_urls).to eq(['https://s3/b.jpg', 'https://s3/c.jpg'])
      expect(request.images.first.id).to eq(kept_id)
      expect(EquipmentRequestImage.where(image_url: 'https://s3/a.jpg')).to be_empty
    end

    it 'clears all images when given an empty list' do
      request = build_request(image_urls: ['https://s3/a.jpg'])
      request.save!

      request.update!(image_urls: [])

      expect(request.reload.image_urls).to eq([])
    end

    it 'rolls back image changes when the update is invalid' do
      request = build_request(image_urls: ['https://s3/a.jpg'])
      request.save!

      expect(request.update(image_urls: ['https://s3/b.jpg'], description: nil)).to eq(false)

      expect(request.reload.image_urls).to eq(['https://s3/a.jpg'])
    end
  end

  it 'destroys its images with it' do
    request = build_request(image_urls: ['https://s3/a.jpg'])
    request.save!

    expect { request.destroy }.to change(EquipmentRequestImage, :count).by(-1)
  end
end
