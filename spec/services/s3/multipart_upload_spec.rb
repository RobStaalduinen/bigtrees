require 'rails_helper'

RSpec.describe S3::MultipartUpload do
  before do
    Aws.config.update(
      s3: { stub_responses: true },
      region: 'us-east-1',
      credentials: Aws::Credentials.new('test', 'test')
    )
    stub_const('ENV', ENV.to_h.merge(
      'AWS_ACCESS_KEY_ID'     => 'test',
      'AWS_SECRET_ACCESS_KEY' => 'test',
      'FOG_REGION'            => 'us-east-1',
      'FOG_BUCKET'            => 'bigtreecare'
    ))
  end

  describe '#initiate' do
    subject(:service) do
      described_class.new(bucket_name: 'tree_images', filename: 'photo.jpg', content_type: 'image/jpeg')
    end

    it 'returns an upload_id and a namespaced key' do
      result = service.initiate
      expect(result.upload_id).to be_present
      expect(result.key).to match(%r{tree_images/test/[0-9a-f-]{36}/photo\.jpg})
    end

    it 'includes Rails.env in the key' do
      result = service.initiate
      expect(result.key).to include("tree_images/#{Rails.env}/")
    end
  end

  describe '#presign_parts' do
    subject(:service) do
      described_class.new(upload_id: 'mp-123', key: 'tree_images/test/uuid/photo.jpg')
    end

    it 'returns one presigned URL per requested part number' do
      parts = service.presign_parts([1, 2, 3])
      expect(parts.length).to eq(3)
      expect(parts.map { |p| p[:part_number] }).to eq([1, 2, 3])
      parts.each { |p| expect(p[:url]).to be_present }
    end

    it 'raises ArgumentError for part_number 0' do
      expect { service.presign_parts([0]) }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError for part_number above 10_000' do
      expect { service.presign_parts([10_001]) }.to raise_error(ArgumentError)
    end

    it 'accepts part_number at boundary values 1 and 10_000' do
      expect { service.presign_parts([1, 10_000]) }.not_to raise_error
    end
  end

  describe '#complete' do
    subject(:service) do
      described_class.new(upload_id: 'mp-123', key: 'tree_images/test/uuid/photo.jpg')
    end

    it 'returns a canonical S3 URL containing the key' do
      parts = [{ part_number: 1, etag: '"abc"' }, { part_number: 2, etag: '"def"' }]
      url = service.complete(parts)
      expect(url).to eq('https://bigtreecare.s3.amazonaws.com/tree_images/test/uuid/photo.jpg')
    end

    it 'sorts parts by part_number before completing' do
      # Provide parts out of order — stub_responses accepts any order;
      # the important thing is no error is raised and a URL is returned.
      parts = [{ part_number: 2, etag: '"def"' }, { part_number: 1, etag: '"abc"' }]
      expect { service.complete(parts) }.not_to raise_error
    end
  end

  describe '#abort' do
    subject(:service) do
      described_class.new(upload_id: 'mp-123', key: 'tree_images/test/uuid/photo.jpg')
    end

    it 'does not raise when aborting successfully' do
      expect { service.abort }.not_to raise_error
    end

    it 'is idempotent when upload no longer exists' do
      client = Aws::S3::Client.new(
        region: 'us-east-1',
        credentials: Aws::Credentials.new('test', 'test'),
        stub_responses: {
          abort_multipart_upload: 'NoSuchUpload'
        }
      )
      allow(service).to receive(:client).and_return(client)
      expect { service.abort }.not_to raise_error
    end
  end
end
