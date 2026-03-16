require 'rails_helper'

RSpec.describe EstimatesController, type: :controller do
  let(:organization) { create(:organization) }
  let(:arborist) { create(:arborist, :admin, organization: organization) }
  let(:customer) { create(:customer) }

  # An estimate that satisfies the INNER joins in index/stats (needs site + customer_detail)
  let(:estimate) do
    create(:estimate, :complete, organization: organization, arborist: arborist, customer: customer)
  end

  before do
    request.cookies[:session_token] = arborist.session_token
    request.headers['X-ORGANIZATION-ID'] = organization.id.to_s
  end

  def sign_out
    request.cookies[:session_token] = nil
  end

  # ---------------------------------------------------------------------------
  # GET #index
  # ---------------------------------------------------------------------------
  describe 'GET #index' do
    context 'when request format is HTML' do
      it 'redirects to the SPA admin path' do
        get :index
        expect(response).to redirect_to('/admin/estimates')
      end
    end

    context 'when request format is JSON' do
      before { estimate }

      it 'returns a 200 with estimates array and pagination meta' do
        get :index, format: :json
        body = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(body['estimates']).to be_an(Array)
        expect(body['meta']['total_entries']).to eq(1)
      end

      it 'scopes estimates to the current organization' do
        other_org      = create(:organization)
        other_arborist = create(:arborist, :admin, organization: other_org)
        other_estimate = create(:estimate, :complete, organization: other_org,
                                                      arborist: other_arborist,
                                                      customer: create(:customer))

        get :index, format: :json
        body = JSON.parse(response.body)
        expect(body['meta']['total_entries']).to eq(1)
        returned_ids = body['estimates'].map { |e| e['id'] }
        expect(returned_ids).not_to include(other_estimate.id)
      end

      context 'with q search param' do
        it 'returns estimates matching the customer name' do
          get :index, params: { q: customer.name }, format: :json
          body = JSON.parse(response.body)
          expect(body['meta']['total_entries']).to eq(1)
        end

        it 'returns no results for a non-matching query' do
          get :index, params: { q: 'zzznomatch' }, format: :json
          body = JSON.parse(response.body)
          expect(body['meta']['total_entries']).to eq(0)
        end
      end

      context 'with only_mine param' do
        it 'returns only estimates assigned to the current user' do
          other_arborist = create(:arborist, :admin, organization: organization)
          create(:estimate, :complete, organization: organization,
                                       arborist: other_arborist,
                                       customer: create(:customer))

          get :index, params: { only_mine: true }, format: :json
          body = JSON.parse(response.body)
          expect(body['meta']['total_entries']).to eq(1)
          expect(body['estimates'].first['arborist']['id']).to eq(arborist.id)
        end
      end

      context 'with assigned_to=me param' do
        it 'returns only estimates assigned to the current user' do
          other_arborist = create(:arborist, :admin, organization: organization)
          create(:estimate, :complete, organization: organization,
                                       arborist: other_arborist,
                                       customer: create(:customer))

          get :index, params: { assigned_to: 'me' }, format: :json
          body = JSON.parse(response.body)
          expect(body['meta']['total_entries']).to eq(1)
        end
      end

      context 'with status param' do
        it 'filters estimates by the given status key' do
          get :index, params: { status: 'active' }, format: :json
          expect(response).to have_http_status(:ok)
          body = JSON.parse(response.body)
          expect(body['estimates']).to be_an(Array)
        end
      end

      context 'with created_after param' do
        it 'filters estimates created within the requested window' do
          get :index, params: { created_after: 'one_week' }, format: :json
          expect(response).to have_http_status(:ok)
          body = JSON.parse(response.body)
          expect(body['estimates']).to be_an(Array)
        end
      end
    end

    context 'when not signed in' do
      before { sign_out }

      it 'redirects to login' do
        get :index
        expect(response).to redirect_to(login_path)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GET #new
  # ---------------------------------------------------------------------------
  describe 'GET #new' do
    context 'with a customer_id param' do
      it 'assigns the found customer' do
        get :new, params: { customer_id: customer.id }
        expect(assigns(:customer)).to eq(customer)
      end
    end

    context 'without a customer_id param' do
      it 'assigns a new Customer' do
        get :new
        expect(assigns(:customer)).to be_a_new(Customer)
      end
    end

    it 'assigns current_user as @arborist' do
      get :new
      expect(assigns(:arborist)).to eq(arborist)
    end

    context 'when not signed in' do
      before { sign_out }

      it 'redirects to login' do
        get :new
        expect(response).to redirect_to(login_path)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GET #show
  # ---------------------------------------------------------------------------
  describe 'GET #show' do
    it 'renders the estimate as JSON' do
      get :show, params: { id: estimate.id }, format: :json
      body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(body['estimate']['id']).to eq(estimate.id)
    end

    context 'when the estimate belongs to a different organization' do
      let(:other_org)      { create(:organization) }
      let(:other_arborist) { create(:arborist, :admin, organization: other_org) }
      let(:other_estimate) do
        create(:estimate, :complete, organization: other_org,
                                     arborist: other_arborist,
                                     customer: customer)
      end

      it 'returns an error (Pundit scope excludes it)' do
        get :show, params: { id: other_estimate.id }, format: :json
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context 'when not signed in' do
      before { sign_out }

      it 'redirects to login' do
        get :show, params: { id: estimate.id }
        expect(response).to redirect_to(login_path)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # POST #create
  # ---------------------------------------------------------------------------
  describe 'POST #create' do
    let(:estimate_attrs) { { tree_quantity: 2 } }

    it 'creates a new estimate and returns its id' do
      expect {
        post :create, params: { estimate: estimate_attrs }, format: :json
      }.to change(Estimate, :count).by(1)

      body = JSON.parse(response.body)
      expect(body['estimate_id']).to be_present
    end

    it 'assigns current_user as arborist when they belong to the org' do
      post :create, params: { estimate: estimate_attrs }, format: :json
      expect(Estimate.last.arborist).to eq(arborist)
    end

    it 'assigns the org default arborist when current user belongs to a different org' do
      other_org      = create(:organization)
      other_arborist = create(:arborist, :admin, organization: other_org)
      request.cookies[:session_token] = other_arborist.session_token
      request.headers['X-ORGANIZATION-ID'] = organization.id.to_s

      post :create, params: { estimate: estimate_attrs }, format: :json
      expect(Estimate.last.arborist).to eq(organization.default_arborist)
    end

    it 'assigns the current organization' do
      post :create, params: { estimate: estimate_attrs }, format: :json
      expect(Estimate.last.organization).to eq(organization)
    end

    context 'with site params' do
      let(:site_attrs) { { wood_removal: true, breakables: false } }

      it 'creates a site for the estimate' do
        expect {
          post :create, params: { estimate: estimate_attrs, site: site_attrs }, format: :json
        }.to change(Site, :count).by(1)

        expect(Estimate.last.site).to be_present
      end
    end

    context 'with customer params for an existing customer' do
      # CustomerPolicy::Scope joins to estimates scoped by org arborists,
      # so the customer must have a prior estimate in the org to be in scope.
      before { create(:estimate, organization: organization, arborist: arborist, customer: customer) }

      it 'associates the existing customer with the estimate' do
        post :create, params: {
          estimate: estimate_attrs,
          customer: { id: customer.id, name: customer.name, email: customer.email }
        }, format: :json

        expect(Estimate.last.customer).to eq(customer)
      end

      it 'creates a customer_detail for the estimate' do
        expect {
          post :create, params: {
            estimate: estimate_attrs,
            customer: { id: customer.id, name: customer.name, email: customer.email }
          }, format: :json
        }.to change(CustomerDetail, :count).by(1)
      end
    end

    context 'with customer params for a new customer' do
      let(:new_customer_attrs) { { name: 'Jane Doe', email: 'jane@example.com', phone: '555-9999' } }

      it 'creates a new customer' do
        expect {
          post :create, params: { estimate: estimate_attrs, customer: new_customer_attrs }, format: :json
        }.to change(Customer, :count).by(1)
      end

      it 'associates the new customer with the estimate' do
        post :create, params: { estimate: estimate_attrs, customer: new_customer_attrs }, format: :json
        expect(Estimate.last.customer.email).to eq('jane@example.com')
      end
    end

    context 'with job params' do
      let(:job_attrs) { { started_at: Time.now, completion_notes: 'All done' } }

      it 'creates a job for the estimate' do
        expect {
          post :create, params: { estimate: estimate_attrs, job: job_attrs }, format: :json
        }.to change(Job, :count).by(1)
      end
    end

    context 'when not signed in' do
      before { sign_out }

      it 'redirects to login' do
        post :create, params: { estimate: estimate_attrs }
        expect(response).to redirect_to(login_path)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # PUT #update
  # ---------------------------------------------------------------------------
  describe 'PUT #update' do
    context 'with JSON format' do
      it 'updates the estimate and returns it' do
        put :update, params: { id: estimate.id, estimate: { tree_quantity: 5 } }, format: :json
        body = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(estimate.reload.tree_quantity).to eq(5)
        expect(body['estimate']['id']).to eq(estimate.id)
      end

      it 'recalculates status after update' do
        # Manually set status to something non-default, then update estimate
        # (without costs, set_status should revert to needs_costs)
        estimate.update_column(:status, 30) # quote_sent
        put :update, params: { id: estimate.id, estimate: { tree_quantity: 3 } }, format: :json
        expect(estimate.reload.status).to eq('needs_costs')
      end
    end

    context 'with HTML format' do
      it 'redirects to the estimate path' do
        put :update, params: { id: estimate.id, estimate: { tree_quantity: 3 } }
        expect(response).to redirect_to(estimate_path(estimate))
      end
    end

    context 'when the estimate belongs to a different organization' do
      let(:other_org)      { create(:organization) }
      let(:other_arborist) { create(:arborist, :admin, organization: other_org) }
      let(:other_estimate) do
        create(:estimate, :complete, organization: other_org,
                                     arborist: other_arborist,
                                     customer: customer)
      end

      it 'returns an error (Pundit scope excludes it)' do
        put :update, params: { id: other_estimate.id, estimate: { tree_quantity: 9 } }, format: :json
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context 'when not authenticated (update is excluded from signed_in_user)' do
      before { sign_out }

      it 'does not redirect but raises an authorization error' do
        put :update, params: { id: estimate.id, estimate: { tree_quantity: 3 } }, format: :json
        # No session → current_user is nil → Pundit / Roles raises an error
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GET #edit
  # ---------------------------------------------------------------------------
  describe 'GET #edit' do
    # Templates for edit sub-forms live at estimates/edit/<form_option>. They are
    # not rendered in the test environment, so we stub render and verify what was
    # requested rather than asserting on response templates.
    before { allow(controller).to receive(:render) }

    context 'when form_option is set_work_date' do
      it 'renders the set_work_date template with admin_material layout' do
        get :edit, params: { id: estimate.id, form_option: 'set_work_date' }
        expect(controller).to have_received(:render).with(
          template: 'estimates/edit/set_work_date',
          layout: 'admin_material'
        )
      end

      it 'assigns the correct estimate' do
        get :edit, params: { id: estimate.id, form_option: 'set_work_date' }
        expect(assigns(:estimate)).to eq(estimate)
      end
    end

    context 'when form_option is another value' do
      it 'renders the corresponding template without the admin_material layout' do
        get :edit, params: { id: estimate.id, form_option: 'notes' }
        expect(controller).to have_received(:render).with(template: 'estimates/edit/notes')
      end
    end

    context 'when not signed in' do
      before do
        sign_out
        allow(controller).to receive(:render).and_call_original
      end

      it 'redirects to login' do
        get :edit, params: { id: estimate.id, form_option: 'set_work_date' }
        expect(response).to redirect_to(login_path)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # POST #cancel
  # ---------------------------------------------------------------------------
  describe 'POST #cancel' do
    it 'returns an empty JSON object' do
      post :cancel, params: { id: estimate.id }, format: :json
      body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(body).to eq({})
    end

    it 'cancels the estimate (state becomes cancelled)' do
      post :cancel, params: { id: estimate.id }, format: :json
      # NOTE: the current implementation calls update(cancelled_at: Date.today), but
      # before_save :set_timestamps clears cancelled_at when state != 'cancelled'.
      # The refactor should update state to 'cancelled' so set_timestamps persists it.
      expect(estimate.reload.state).to eq('cancelled')
    end

    it 'sets cancelled_at' do
      post :cancel, params: { id: estimate.id }, format: :json
      expect(estimate.reload.cancelled_at).to be_present
    end

    context 'when not signed in' do
      before { sign_out }

      it 'redirects to login' do
        post :cancel, params: { id: estimate.id }
        expect(response).to redirect_to(login_path)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GET #stats
  # ---------------------------------------------------------------------------
  describe 'GET #stats' do
    before { estimate }

    it 'returns counts for each expected status key' do
      get :stats, format: :json
      body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(body.keys).to match_array(%w[quoting quote_sent approved scheduled working invoice_sent])
    end

    it 'counts in_progress estimates in each bucket' do
      get :stats, format: :json
      body = JSON.parse(response.body)
      # Estimate has no costs → quoting status
      expect(body['quoting']).to eq(1)
    end

    it 'excludes completed (done-state) estimates' do
      estimate.update!(state: 'done')

      get :stats, format: :json
      body = JSON.parse(response.body)
      expect(body['quoting']).to eq(0)
    end

    context 'when not signed in' do
      before { sign_out }

      it 'redirects to login' do
        get :stats
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
