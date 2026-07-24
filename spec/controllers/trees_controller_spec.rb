require 'rails_helper'

RSpec.describe TreesController, type: :controller do
  let(:organization) { create(:organization) }
  let(:arborist) { create(:arborist, :admin, organization: organization) }
  let(:customer) { create(:customer) }
  let(:estimate) { create(:estimate, :complete, organization: organization, arborist: arborist, customer: customer) }

  before do
    request.cookies[:session_token] = arborist.session_token
    request.headers['X-ORGANIZATION-ID'] = organization.id.to_s
  end

  describe 'POST #bulk_create' do
    it 'returns tree_ids in input order and creates no images' do
      expect {
        post :bulk_create, params: {
          estimate_id: estimate.id,
          trees: [
            { description: 'Maple out front' },
            { description: 'Oak in the back' },
            { description: 'Cedar by the fence' }
          ],
          format: :json
        }
      }.to change(TreeImage, :count).by(0)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      tree_ids = body['tree_ids']

      expect(tree_ids.length).to eq(3)
      created = tree_ids.map { |id| Tree.find(id) }
      expect(created.map(&:description)).to eq(['Maple out front', 'Oak in the back', 'Cedar by the fence'])
      expect(created.map(&:estimate_id).uniq).to eq([estimate.id])
    end
  end
end
