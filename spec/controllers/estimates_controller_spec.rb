require 'rails_helper'

RSpec.describe EstimatesController, type: :controller do
  let(:organization) { create(:organization) }
  # Arborist has no `belongs_to :organization`; use organization_id directly.
  let(:admin)    { create(:admin, organization_id: organization.id) }
  # Base :arborist factory has role: 'arborist' from DB default column.
  let(:arborist) { create(:arborist, organization_id: organization.id) }
  let(:estimate) { create(:estimate, organization: organization, arborist: admin) }

  before do
    allow(OrganizationContext).to receive(:set_current_organization)
    allow(OrganizationContext).to receive(:current_organization).and_return(organization)
    allow(Sentry).to receive(:capture_exception)
  end

  # Creates an estimate with the full set of associations required by the
  # index/stats JOIN chain (customer, site, customer_detail).
  def create_indexed_estimate(arborist: admin, **attrs)
    e = create(:estimate, organization: organization, arborist: arborist, **attrs)
    CustomerDetail.create!(
      estimate: e,
      name:     'Test Customer',
      email:    'test@example.com',
      phone:    '555-0000'
    )
    e
  end

  # ---------------------------------------------------------------------------
  # GET #index
  # ---------------------------------------------------------------------------
  describe 'GET #index' do
    context 'when not signed in' do
      before { log_out_users }

      it 'redirects to login' do
        get :index
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when signed in as admin' do
      before { log_in_user(admin) }

      it 'redirects to /admin/estimates for HTML requests' do
        get :index
        expect(response).to redirect_to('/admin/estimates')
      end

      context 'JSON format' do
        let!(:full_estimate) { create_indexed_estimate }

        it 'returns HTTP 200' do
          get :index, format: :json
          expect(response).to have_http_status(200)
        end

        it 'returns a JSON array' do
          get :index, format: :json
          json = JSON.parse(response.body)
          expect(json).to be_an(Array)
        end

        it 'includes total_entries in the response' do
          get :index, format: :json
          expect(response.body).to include('total_entries')
        end

        context 'policy scope' do
          let!(:other_org)    { create(:organization) }
          let!(:other_admin)  { create(:admin, organization_id: other_org.id) }
          let!(:other_estimate) do
            e = create(:estimate, organization: other_org, arborist: other_admin)
            CustomerDetail.create!(estimate: e, name: 'Other Org', email: 'other@org.com', phone: '000')
            e
          end

          it 'only returns estimates in the current organization' do
            get :index, format: :json
            json  = JSON.parse(response.body)
            ids   = json.map { |e| e['id'] }
            expect(ids).to include(full_estimate.id)
            expect(ids).not_to include(other_estimate.id)
          end
        end

        context 'filtering by params[:status]' do
          let!(:needs_costs_estimate) do
            create_indexed_estimate(state: :in_progress, status: :needs_costs)
          end

          it 'returns only estimates matching that status' do
            get :index, format: :json, params: { status: 'needs_pricing' }
            json = JSON.parse(response.body)
            ids  = json.map { |e| e['id'] }
            expect(ids).to include(needs_costs_estimate.id)
          end
        end

        context 'filtering by params[:created_after]' do
          it 'returns HTTP 200 and does not raise' do
            get :index, format: :json, params: { created_after: 'one_week' }
            expect(response).to have_http_status(200)
          end
        end

        context 'filtering by params[:only_mine]' do
          let!(:other_admin2)    { create(:admin, organization_id: organization.id) }
          let!(:other_estimate2) { create_indexed_estimate(arborist: other_admin2) }

          it 'returns only estimates assigned to current_user' do
            get :index, format: :json, params: { only_mine: true }
            json = JSON.parse(response.body)
            ids  = json.map { |e| e['id'] }
            expect(ids).to include(full_estimate.id)
            expect(ids).not_to include(other_estimate2.id)
          end
        end

        context 'filtering by params[:assigned_to] = "me"' do
          let!(:other_admin3)    { create(:admin, organization_id: organization.id) }
          let!(:other_estimate3) { create_indexed_estimate(arborist: other_admin3) }

          it 'returns only current_user estimates' do
            get :index, format: :json, params: { assigned_to: 'me' }
            json = JSON.parse(response.body)
            ids  = json.map { |e| e['id'] }
            expect(ids).to include(full_estimate.id)
            expect(ids).not_to include(other_estimate3.id)
          end
        end

        context 'search (params[:q])' do
          it 'matches customer name case-insensitively (customer factory name is "Max Power")' do
            get :index, format: :json, params: { q: 'max power' }
            json = JSON.parse(response.body)
            expect(json.map { |e| e['id'] }).to include(full_estimate.id)
          end

          it 'returns no results for a query with no match' do
            get :index, format: :json, params: { q: 'zzznomatchxxx' }
            json = JSON.parse(response.body)
            expect(json).to be_an(Array).and be_empty
          end
        end

        context 'pagination' do
          before do
            2.times { create_indexed_estimate }
          end

          it 'limits results by per_page' do
            get :index, format: :json, params: { per_page: 1, page: 1 }
            json = JSON.parse(response.body)
            expect(json.length).to eq(1)
          end

          it 'advances to subsequent pages' do
            get :index, format: :json, params: { per_page: 2, page: 2 }
            json = JSON.parse(response.body)
            # 3 estimates total (full_estimate + 2 from before); page 2 has 1
            expect(json.length).to eq(1)
          end
        end
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GET #new
  # ---------------------------------------------------------------------------
  describe 'GET #new' do
    context 'when not signed in' do
      before { log_out_users }

      it 'redirects to login' do
        get :new
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when signed in as admin' do
      before { log_in_user(admin) }

      context 'without customer_id' do
        it 'assigns @customer as a new Customer' do
          get :new
          expect(assigns(:customer)).to be_a_new(Customer)
        end

        it 'assigns @last_estimate as a new Estimate' do
          get :new
          expect(assigns(:last_estimate)).to be_a_new(Estimate)
        end
      end

      context 'with a valid customer_id' do
        let!(:customer) { create(:customer) }

        it 'assigns the existing customer' do
          get :new, params: { customer_id: customer.id }
          expect(assigns(:customer)).to eq(customer)
        end

        it 'assigns @last_estimate from the customer last estimate' do
          est = create(:estimate, organization: organization, arborist: admin, customer: customer)
          get :new, params: { customer_id: customer.id }
          expect(assigns(:last_estimate)).to eq(est)
        end
      end

      it 'assigns @arborist as current_user' do
        get :new
        expect(assigns(:arborist)).to eq(admin)
      end
    end

    context 'when signed in as arborist (create: false)' do
      before { log_in_user(arborist) }

      it 'returns an unauthorized error response' do
        get :new
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GET #show
  # ---------------------------------------------------------------------------
  describe 'GET #show' do
    context 'when not signed in' do
      before { log_out_users }

      it 'redirects to login' do
        get :show, params: { id: estimate.id }
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when signed in as admin' do
      before { log_in_user(admin) }

      it 'returns HTTP 200 with estimate JSON for a valid id in scope' do
        get :show, params: { id: estimate.id }
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json['id']).to eq(estimate.id)
      end

      it 'returns a 500 error for an id outside the current org scope (RecordNotFound caught by rescue_from)' do
        other_org     = create(:organization)
        other_admin   = create(:admin, organization_id: other_org.id)
        other_estimate = create(:estimate, organization: other_org, arborist: other_admin)

        get :show, params: { id: other_estimate.id }
        expect(response).to have_http_status(:internal_server_error)
      end

      # BUG DOCUMENTED: the show action calls `authorize Customer, :show?`
      # rather than `authorize Estimate, :show?`. This is the current behavior.
      it 'authorizes via CustomerPolicy#show? rather than EstimatePolicy#show?' do
        expect_any_instance_of(EstimatePolicy).not_to receive(:show?)
        expect_any_instance_of(CustomerPolicy).to receive(:show?).and_call_original
        get :show, params: { id: estimate.id }
      end
    end
  end

  # ---------------------------------------------------------------------------
  # POST #create
  # ---------------------------------------------------------------------------
  describe 'POST #create' do
    let(:valid_estimate_params) { { tree_quantity: 2, submission_completed: true } }

    context 'when not signed in' do
      before { log_out_users }

      it 'redirects to login' do
        post :create, params: { estimate: valid_estimate_params }
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when signed in as admin' do
      before { log_in_user(admin) }

      it 'creates an Estimate' do
        expect {
          post :create, params: { estimate: valid_estimate_params }
        }.to change(Estimate, :count).by(1)
      end

      it 'returns the new estimate_id as JSON' do
        post :create, params: { estimate: valid_estimate_params }
        json = JSON.parse(response.body)
        expect(json['estimate_id']).to be_present
      end

      it 'sets the organization on the created estimate' do
        post :create, params: { estimate: valid_estimate_params }
        expect(Estimate.last.organization).to eq(organization)
      end

      context 'arborist assignment' do
        it 'assigns current_user when in the same org' do
          post :create, params: { estimate: valid_estimate_params }
          expect(Estimate.last.arborist).to eq(admin)
        end

        context 'when current_user belongs to a different org' do
          let!(:other_org)     { create(:organization) }
          let!(:default_arb)   { create(:admin, organization_id: other_org.id) }

          before do
            allow(OrganizationContext).to receive(:current_organization).and_return(other_org)
            allow(other_org).to receive(:default_arborist).and_return(default_arb)
            log_in_user(admin) # admin.organization_id != other_org.id
          end

          it 'assigns the org default_arborist' do
            post :create, params: { estimate: valid_estimate_params }
            expect(Estimate.last.arborist).to eq(default_arb)
          end
        end
      end

      context 'with site params' do
        let(:site_params) do
          { address_attributes: { street: '123 Main St', city: 'Treeville' } }
        end

        it 'creates a Site on the estimate' do
          post :create, params: { estimate: valid_estimate_params, site: site_params }
          new_estimate = Estimate.last
          expect(new_estimate.site).to be_present
        end
      end

      context 'with customer params — existing customer found by id' do
        let!(:existing_customer) do
          create(:customer, name: 'Existing', email: 'existing@test.com', phone: '111-111-1111')
        end
        let(:customer_params) do
          { id: existing_customer.id, name: 'Existing', email: 'existing@test.com', phone: '111-111-1111' }
        end

        it 'associates the existing customer without creating a new Customer record' do
          expect {
            post :create, params: { estimate: valid_estimate_params, customer: customer_params }
          }.not_to change(Customer, :count)

          expect(Estimate.last.customer).to eq(existing_customer)
        end
      end

      context 'with customer params — no id match' do
        let(:customer_params) do
          { name: 'Brand New', email: 'brand@new.com', phone: '999-999-9999' }
        end

        it 'creates a new Customer record' do
          expect {
            post :create, params: { estimate: valid_estimate_params, customer: customer_params }
          }.to change(Customer, :count).by(1)
        end
      end

      context 'with customer params' do
        let(:customer_params) do
          { name: 'Detail Name', email: 'detail@test.com', phone: '777-777-7777' }
        end

        it 'creates a CustomerDetail on the estimate' do
          expect {
            post :create, params: { estimate: valid_estimate_params, customer: customer_params }
          }.to change(CustomerDetail, :count).by(1)
        end
      end

      context 'with job params (no assigned_arborists)' do
        let(:job_params) { { started_at: nil, completed_at: nil } }

        it 'creates a Job on the estimate' do
          expect {
            post :create, params: { estimate: valid_estimate_params, job: job_params }
          }.to change(Job, :count).by(1)
        end
      end

      context 'with job params and assigned_arborists' do
        let(:other_arborist) { create(:arborist, organization_id: organization.id) }
        let(:job_params)     { { assigned_arborists: [other_arborist.id] } }

        it 'creates a JobAssignment per arborist id' do
          expect {
            post :create, params: { estimate: valid_estimate_params, job: job_params }
          }.to change(JobAssignment, :count).by(1)
        end
      end
    end

    context 'when signed in as arborist (create: false)' do
      before { log_in_user(arborist) }

      it 'returns an unauthorized error response' do
        post :create, params: { estimate: valid_estimate_params }
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # PATCH #update
  # ---------------------------------------------------------------------------
  describe 'PATCH #update' do
    context 'when not signed in' do
      before { log_out_users }

      # update is excluded from `before_action :signed_in_user`, so no redirect.
      # Pundit raises an error (current_user nil), caught by rescue_from StandardError.
      it 'does NOT redirect to login' do
        patch :update, params: { id: estimate.id, estimate: { tree_quantity: 5 } }, format: :json
        expect(response).not_to be_redirect
      end

      it 'returns an error response (rescue_from catches Pundit error)' do
        patch :update, params: { id: estimate.id, estimate: { tree_quantity: 5 } }, format: :json
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context 'when signed in as admin' do
      before { log_in_user(admin) }

      it 'updates the estimate and returns HTTP 200 with JSON' do
        patch :update, params: { id: estimate.id, estimate: { tree_quantity: 5 } }, format: :json
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json['id']).to eq(estimate.id)
      end

      it 'calls set_status on the estimate' do
        expect_any_instance_of(Estimate).to receive(:set_status).at_least(:once)
        patch :update, params: { id: estimate.id, estimate: { tree_quantity: 5 } }, format: :json
      end

      it 'redirects to estimate_path for HTML format' do
        patch :update, params: { id: estimate.id, estimate: { tree_quantity: 5 } }
        expect(response).to redirect_to(estimate_path(estimate))
      end

      it 'returns 500 for an estimate outside org scope (RecordNotFound caught by rescue_from)' do
        other_org      = create(:organization)
        other_admin    = create(:admin, organization_id: other_org.id)
        other_estimate = create(:estimate, organization: other_org, arborist: other_admin)

        patch :update, params: { id: other_estimate.id, estimate: { tree_quantity: 5 } }, format: :json
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context 'when signed in as arborist (update: false)' do
      before { log_in_user(arborist) }

      it 'returns an unauthorized error response' do
        patch :update, params: { id: estimate.id, estimate: { tree_quantity: 5 } }, format: :json
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GET #edit
  # ---------------------------------------------------------------------------
  describe 'GET #edit' do
    context 'when not signed in' do
      before { log_out_users }

      it 'redirects to login' do
        get :edit, params: { id: estimate.id, form_option: 'set_work_date' }
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when signed in as admin' do
      before { log_in_user(admin) }

      it 'assigns @estimate' do
        get :edit, params: { id: estimate.id, form_option: 'set_work_date' }
        expect(assigns(:estimate)).to eq(estimate)
      end

      context 'with form_option "set_work_date"' do
        it 'renders estimates/edit/set_work_date with the admin_material layout' do
          get :edit, params: { id: estimate.id, form_option: 'set_work_date' }
          expect(response).to render_template('estimates/edit/set_work_date')
          expect(response).to render_template(layout: 'layouts/admin_material')
        end
      end

      context 'with a different form_option' do
        it 'renders estimates/edit/<form_option> without the admin_material layout' do
          get :edit, params: { id: estimate.id, form_option: 'some_other_form' }
          expect(response).to render_template('estimates/edit/some_other_form')
          expect(response).not_to render_template(layout: 'layouts/admin_material')
        end
      end
    end
  end

  # ---------------------------------------------------------------------------
  # POST #cancel
  # ---------------------------------------------------------------------------
  describe 'POST #cancel' do
    context 'when not signed in' do
      before { log_out_users }

      it 'redirects to login' do
        post :cancel, params: { id: estimate.id }
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when signed in as admin' do
      before { log_in_user(admin) }

      it 'returns HTTP 200 with an empty JSON object' do
        post :cancel, params: { id: estimate.id }
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to eq({})
      end

      it 'sets cancelled_at to Date.today' do
        travel_to Time.zone.local(2026, 3, 8) do
          post :cancel, params: { id: estimate.id }
          expect(estimate.reload.cancelled_at).to eq(Date.new(2026, 3, 8))
        end
      end

      # BEHAVIORAL NOTE: cancel uses Estimate.find (not policy_scope), so it can
      # act on estimates outside the current org scope — unlike show and update.
      it 'finds estimates outside org scope (uses Estimate.find, not policy_scope)' do
        other_org      = create(:organization)
        other_admin    = create(:admin, organization_id: other_org.id)
        other_estimate = create(:estimate, organization: other_org, arborist: other_admin)

        post :cancel, params: { id: other_estimate.id }
        expect(response).to have_http_status(200)
        expect(other_estimate.reload.cancelled_at).to be_present
      end
    end

    context 'when signed in as arborist (update: false)' do
      before { log_in_user(arborist) }

      it 'returns an unauthorized error response' do
        post :cancel, params: { id: estimate.id }
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GET #stats
  # ---------------------------------------------------------------------------
  describe 'GET #stats' do
    context 'when not signed in' do
      before { log_out_users }

      it 'redirects to login' do
        get :stats
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when signed in as admin' do
      before { log_in_user(admin) }

      it 'returns HTTP 200' do
        get :stats
        expect(response).to have_http_status(200)
      end

      it 'returns JSON with all required stat keys' do
        get :stats
        json = JSON.parse(response.body)
        expect(json.keys).to include('needs_costs', 'quote_sent', 'approved', 'scheduled', 'completed', 'invoice_sent')
      end

      it 'does not include done or cancelled estimates in any count' do
        done_estimate = create_indexed_estimate(state: :done)

        get :stats
        json = JSON.parse(response.body)
        expect(json.values.sum).to eq(0)
      end

      it 'counts needs_costs estimates correctly' do
        create_indexed_estimate(state: :in_progress, status: :needs_costs)

        get :stats
        json = JSON.parse(response.body)
        expect(json['needs_costs']).to eq(1)
      end

      it 'counts quote_sent estimates correctly' do
        create_indexed_estimate(state: :in_progress, status: :quote_sent)

        get :stats
        json = JSON.parse(response.body)
        expect(json['quote_sent']).to eq(1)
      end

      it 'counts approved estimates correctly' do
        create_indexed_estimate(state: :in_progress, status: :approved)

        get :stats
        json = JSON.parse(response.body)
        expect(json['approved']).to eq(1)
      end

      context 'with params[:only_mine] filter' do
        let!(:other_admin2)    { create(:admin, organization_id: organization.id) }
        let!(:mine_estimate)   { create_indexed_estimate(state: :in_progress, status: :needs_costs) }
        let!(:theirs_estimate) { create_indexed_estimate(arborist: other_admin2, state: :in_progress, status: :needs_costs) }

        it 'reduces counts to only current_user estimates' do
          get :stats, params: { only_mine: true }
          json = JSON.parse(response.body)
          expect(json['needs_costs']).to eq(1)
        end
      end

      context 'with params[:q] that matches nothing' do
        let!(:in_prog_estimate) { create_indexed_estimate(state: :in_progress, status: :needs_costs) }

        it 'returns all-zero counts' do
          get :stats, params: { q: 'zzznomatchxxx' }
          json = JSON.parse(response.body)
          expect(json.values.all? { |v| v == 0 }).to be true
        end
      end
    end
  end
end
