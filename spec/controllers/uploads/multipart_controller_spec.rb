require 'rails_helper'

RSpec.describe Uploads::MultipartController, type: :controller do
  let(:organization) { create(:organization) }
  let(:arborist)     { create(:arborist, :admin, organization: organization) }

  before do
    request.cookies[:session_token] = arborist.session_token
    request.headers['X-ORGANIZATION-ID'] = organization.id.to_s

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

  def sign_out
    request.cookies[:session_token] = nil
  end

  # ---------------------------------------------------------------------------
  # POST #create
  # ---------------------------------------------------------------------------
  describe 'POST #create' do
    let(:valid_params) { { bucket_name: 'tree_images', filename: 'photo.jpg', content_type: 'image/jpeg' } }

    it 'returns 200 with upload_id and key' do
      post :create, params: valid_params, format: :json
      body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(body['upload_id']).to be_present
      expect(body['key']).to match(%r{tree_images/test/[0-9a-f-]{36}/photo\.jpg})
    end

    it 'returns 502 when S3 raises a service error' do
      allow_any_instance_of(S3::MultipartUpload).to receive(:initiate).and_raise(
        Aws::S3::Errors::ServiceError.new(nil, 'S3 unavailable')
      )
      post :create, params: valid_params, format: :json
      expect(response).to have_http_status(:bad_gateway)
      expect(JSON.parse(response.body)['error']).to be_present
    end

    context 'when unauthenticated' do
      before { sign_out }

      it 'still returns 200 (mirrors FilesController — no auth guard on presigned URL endpoints)' do
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # POST #parts
  # ---------------------------------------------------------------------------
  describe 'POST #parts' do
    let(:valid_params) { { upload_id: 'mp-123', key: 'tree_images/test/uuid/photo.jpg', part_numbers: [1, 2, 3] } }

    it 'returns 200 with presigned URLs for each part' do
      post :parts, params: valid_params, format: :json
      body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(body['parts'].length).to eq(3)
    end

    it 'returns 422 for invalid part numbers' do
      post :parts, params: valid_params.merge(part_numbers: [0]), format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  # ---------------------------------------------------------------------------
  # POST #complete
  # ---------------------------------------------------------------------------
  describe 'POST #complete' do
    let(:valid_params) do
      {
        upload_id: 'mp-123',
        key: 'tree_images/test/uuid/photo.jpg',
        parts: [{ part_number: 1, etag: '"abc"' }, { part_number: 2, etag: '"def"' }]
      }
    end

    it 'returns 200 with the canonical S3 URL' do
      post :complete, params: valid_params, format: :json
      body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(body['url']).to eq('https://bigtreecare.s3.amazonaws.com/tree_images/test/uuid/photo.jpg')
    end

    it 'returns 422 when a part is too small' do
      allow_any_instance_of(S3::MultipartUpload).to receive(:complete).and_raise(
        Aws::S3::Errors::EntityTooSmall.new(nil, 'too small')
      )
      post :complete, params: valid_params, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 502 on other S3 errors' do
      allow_any_instance_of(S3::MultipartUpload).to receive(:complete).and_raise(
        Aws::S3::Errors::ServiceError.new(nil, 'S3 error')
      )
      post :complete, params: valid_params, format: :json
      expect(response).to have_http_status(:bad_gateway)
    end
  end

  # ---------------------------------------------------------------------------
  # DELETE #destroy
  # ---------------------------------------------------------------------------
  describe 'DELETE #destroy' do
    let(:valid_params) { { upload_id: 'mp-123', key: 'tree_images/test/uuid/photo.jpg' } }

    it 'returns 204' do
      delete :destroy, params: valid_params, format: :json
      expect(response).to have_http_status(:no_content)
    end

    it 'is idempotent — returns 204 when upload does not exist' do
      allow_any_instance_of(S3::MultipartUpload).to receive(:abort)
      delete :destroy, params: valid_params, format: :json
      expect(response).to have_http_status(:no_content)
    end

    it 'returns 502 on unexpected S3 errors' do
      allow_any_instance_of(S3::MultipartUpload).to receive(:abort).and_raise(
        Aws::S3::Errors::ServiceError.new(nil, 'S3 error')
      )
      delete :destroy, params: valid_params, format: :json
      expect(response).to have_http_status(:bad_gateway)
    end
  end
end
