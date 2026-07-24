require 'rails_helper'

RSpec.describe TreeImagesController, type: :controller do
  let(:organization) { create(:organization) }
  let(:arborist) { create(:arborist, :admin, organization: organization) }
  let(:customer) { create(:customer) }
  let(:estimate) { create(:estimate, :complete, organization: organization, arborist: arborist, customer: customer) }
  let(:client_upload_id) { SecureRandom.uuid }

  before do
    request.cookies[:session_token] = arborist.session_token
    request.headers['X-ORGANIZATION-ID'] = organization.id.to_s
  end

  describe 'GET #show' do
    it 'returns 204 for a pending (URL-less) image instead of raising' do
      tree_image = TreeImage.create!(estimate: estimate, image_url: nil)

      get :show, params: { id: tree_image.id }

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'POST #associate' do
    it 'creates a pending (URL-less) row when no image_url is given' do
      expect {
        post :associate, params: {
          estimate_id: estimate.id,
          client_upload_id: client_upload_id,
          format: :json
        }
      }.to change(TreeImage, :count).by(1)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)['tree_image']
      expect(body['image_url']).to be_nil
      expect(body['ready']).to eq(false)
      expect(body['id']).to be_present

      tree_image = TreeImage.find(body['id'])
      expect(tree_image.client_upload_id).to eq(client_upload_id)
      expect(tree_image.estimate_id).to eq(estimate.id)
    end

    it 'associates the row to a tree when tree_id is given' do
      tree = Tree.create!(estimate: estimate, work_type: 'other')

      post :associate, params: {
        estimate_id: estimate.id,
        tree_id: tree.id,
        client_upload_id: client_upload_id,
        format: :json
      }

      body = JSON.parse(response.body)['tree_image']
      expect(body['tree_id']).to eq(tree.id)
    end

    it 'fills the URL on a second call with the same client_upload_id (one row, now ready)' do
      post :associate, params: {
        estimate_id: estimate.id,
        client_upload_id: client_upload_id,
        format: :json
      }
      first_id = JSON.parse(response.body)['tree_image']['id']

      expect {
        post :associate, params: {
          estimate_id: estimate.id,
          client_upload_id: client_upload_id,
          image_url: 'https://example.com/photo.jpg',
          format: :json
        }
      }.not_to change(TreeImage, :count)

      body = JSON.parse(response.body)['tree_image']
      expect(body['id']).to eq(first_id)
      expect(body['image_url']).to eq('https://example.com/photo.jpg')
      expect(body['ready']).to eq(true)
      expect(TreeImage.where(client_upload_id: client_upload_id).count).to eq(1)
    end

    it 'never overwrites an existing URL with nil on a later call' do
      post :associate, params: {
        estimate_id: estimate.id,
        client_upload_id: client_upload_id,
        image_url: 'https://example.com/photo.jpg',
        format: :json
      }

      post :associate, params: {
        estimate_id: estimate.id,
        client_upload_id: client_upload_id,
        format: :json
      }

      body = JSON.parse(response.body)['tree_image']
      expect(body['image_url']).to eq('https://example.com/photo.jpg')
      expect(body['ready']).to eq(true)
    end

    it 'is unauthorized for a role without estimate update permission' do
      unauthorized = create(:arborist, :arborist_role, organization: organization)
      request.cookies[:session_token] = unauthorized.session_token

      expect {
        post :associate, params: {
          estimate_id: estimate.id,
          client_upload_id: client_upload_id,
          format: :json
        }
      }.not_to change(TreeImage, :count)

      expect(response).to have_http_status(:internal_server_error)
    end
  end
end
