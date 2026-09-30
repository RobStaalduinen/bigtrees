require 'rails_helper'

RSpec.describe QuoteScopesController, type: :controller do
  let(:organization) { create(:organization) }
  let(:arborist) { create(:arborist, :admin, organization: organization) }
  let(:estimate) { create(:estimate, organization: organization) }

  before do
    request.cookies[:session_token] = arborist.session_token
    request.headers['X-ORGANIZATION-ID'] = organization.id.to_s
  end

  def scope_for(est)
    est.reload.quote_scope
  end

  describe 'POST #update' do
    it 'creates the record on first save' do
      expect {
        post :update, params: {
          estimate_id: estimate.id,
          scope_of_work: 'Remove two silver maples.',
          inclusions: ['Stump grinding', 'Brush haul-away'],
          exclusions: ['Topsoil or sod'],
          format: :json
        }
      }.to change(QuoteScope, :count).by(1)

      expect(response).to have_http_status(:ok)

      scope = scope_for(estimate)
      expect(scope.scope_of_work).to eq('Remove two silver maples.')
      expect(scope.inclusions).to eq(['Stump grinding', 'Brush haul-away'])
      expect(scope.exclusions).to eq(['Topsoil or sod'])
    end

    it 'updates in place rather than adding a second record' do
      QuoteScope.create!(estimate: estimate, scope_of_work: 'Old text', inclusions: ['Old item'])

      expect {
        post :update, params: {
          estimate_id: estimate.id,
          scope_of_work: 'New text',
          inclusions: ['New item'],
          format: :json
        }
      }.not_to change(QuoteScope, :count)

      scope = scope_for(estimate)
      expect(scope.scope_of_work).to eq('New text')
      expect(scope.inclusions).to eq(['New item'])
    end

    it 'clears lists when the editor submits none' do
      QuoteScope.create!(estimate: estimate, inclusions: %w[a b], exclusions: %w[c])

      post :update, params: { estimate_id: estimate.id, scope_of_work: '', format: :json }

      scope = scope_for(estimate)
      expect(scope.inclusions).to eq([])
      expect(scope.exclusions).to eq([])
      expect(scope.scope_of_work).to be_blank
    end

    it 'returns the estimate with the scope embedded so the client can refresh' do
      post :update, params: {
        estimate_id: estimate.id,
        scope_of_work: 'Remove two silver maples.',
        inclusions: ['Stump grinding'],
        format: :json
      }

      payload = JSON.parse(response.body)['estimate']['quote_scope']
      expect(payload['scope_of_work']).to eq('Remove two silver maples.')
      expect(payload['inclusions']).to eq(['Stump grinding'])
    end

    it 'does not touch an estimate belonging to another organization' do
      other = create(:estimate, organization: create(:organization))

      # policy_scope raises RecordNotFound, but ApplicationController's blanket
      # `rescue_from StandardError` turns it into a 500 rather than a 404 — so
      # assert on the outcome (nothing written) rather than the exception.
      expect {
        post :update, params: { estimate_id: other.id, scope_of_work: 'Nope', format: :json }
      }.not_to change(QuoteScope, :count)

      expect(response).not_to have_http_status(:ok)
      expect(other.reload.quote_scope).to be_nil
    end
  end
end
