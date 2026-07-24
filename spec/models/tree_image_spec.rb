require 'rails_helper'

RSpec.describe TreeImage, type: :model do
  describe '#imgix_url' do
    it 'returns nil for a pending (URL-less) image instead of raising' do
      expect(TreeImage.new(image_url: nil).imgix_url).to be_nil
    end

    it 'rewrites the bucket URL to the imgix CDN when a URL is present' do
      url = "#{TreeImage::BUCKET_URL}/tree_images/photo.jpg?X-Amz=sig"
      expect(TreeImage.new(image_url: url).imgix_url).to eq("#{TreeImage::IMGIX_CDN}/tree_images/photo.jpg")
    end
  end
end
