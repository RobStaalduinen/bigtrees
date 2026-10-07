require 'rails_helper'

RSpec.describe EquipmentRequestsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:arborist) { create(:arborist, :admin, organization: organization) }

  before do
    request.cookies[:session_token] = arborist.session_token
    request.headers['X-ORGANIZATION-ID'] = organization.id.to_s
  end

  def request_params(attrs = {})
    { category: 'mechanical', description: 'Chipper belt is slipping' }.merge(attrs)
  end

  describe 'POST #create' do
    it 'stores multiple images and returns them' do
      post :create, params: {
        equipment_request: request_params(image_urls: ['https://s3/a.jpg', 'https://s3/b.jpg']),
        format: :json
      }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)['equipment_request']
      expect(body['image_urls']).to eq(['https://s3/a.jpg', 'https://s3/b.jpg'])
      expect(EquipmentRequest.last.images.count).to eq(2)
    end
  end

  describe 'PUT #update' do
    let!(:equipment_request) do
      EquipmentRequest.create!(
        request_params(organization: organization, arborist: arborist, image_urls: ['https://s3/a.jpg'])
      )
    end

    it 'replaces the images with the submitted list' do
      put :update, params: {
        id: equipment_request.id,
        equipment_request: request_params(image_urls: ['https://s3/a.jpg', 'https://s3/c.jpg']),
        format: :json
      }

      expect(response).to have_http_status(:ok)
      expect(equipment_request.reload.image_urls).to eq(['https://s3/a.jpg', 'https://s3/c.jpg'])
    end

    it 'leaves images untouched when image_urls is not sent' do
      put :update, params: {
        id: equipment_request.id,
        equipment_request: request_params(description: 'Updated'),
        format: :json
      }

      expect(equipment_request.reload.image_urls).to eq(['https://s3/a.jpg'])
    end
  end

  describe 'GET #index' do
    it 'includes every image on each request' do
      EquipmentRequest.create!(
        request_params(organization: organization, arborist: arborist, image_urls: ['https://s3/a.jpg', 'https://s3/b.jpg'])
      )

      get :index, format: :json

      body = JSON.parse(response.body)['equipment_requests']
      expect(body.first['image_urls']).to eq(['https://s3/a.jpg', 'https://s3/b.jpg'])
    end
  end
end
