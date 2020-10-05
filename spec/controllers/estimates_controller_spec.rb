describe EstimatesController do
  let!(:arborist) { create(:admin) }

  before do
    log_in_user(arborist)
  end

  describe "Auth" do
    let!(:estimate) { create(:estimate) }

    context "without user" do
      before do
        log_out_users
      end

      it "redirects new" do
        get :new
        should redirect_to(login_path)
      end

      it "redirects show" do
        get :show, { id: estimate.id }
        should redirect_to(login_path)
      end
    end
  end

  describe 'index' do
    render_views
    let(:params) { {} }
    subject(:get_request) do
      get :index, params.merge({ format: :json })
      response
    end
    let(:parsed_response) { JSON.parse(get_request.body) }

    context 'with single estimate' do
      let!(:estimate) { create(:estimate) }

      it { should have_http_status(:ok) }

      it 'has a single estimate' do
        expect(parsed_response['estimates'].count).to eq(1)
        expect(parsed_response['total_entries']).to eq(1)
      end

      it 'has correct format' do
        first_estimate = parsed_response['estimates'].first
        expect(first_estimate['id']).to eq(estimate.id)
        expect(first_estimate['customer']['id']).to eq(estimate.customer.id)
        expect(first_estimate['customer']['name']).to eq(estimate.customer.name) 
      end
    end

    describe 'Pagination' do
      before do
        3.times { create(:estimate) }
      end

      context 'with per_page param' do
        let(:params) { { per_page: 2 } }

        it 'limits response length' do
          expect(parsed_response['estimates'].count).to eq(2)
          expect(parsed_response['total_entries']).to eq(3)
        end
      end

      context 'with page param' do
        let(:params) { { per_page: 2, page: 2 } }

        it 'offsets response' do
          expect(parsed_response['estimates'].count).to eq(1)
          expect(parsed_response['total_entries']).to eq(3)
        end
      end
    end

    describe 'Search' do
      let(:first_site) { create(:site, street: 'Division St', city: 'Kingston') }
      let(:first_customer) { create(:customer, name: 'Rob Staalduinen', email: 'rob.staalduinen@gmail.com', phone: '1112223333') }
      let!(:first_estimate) { create(:estimate, customer: first_customer, site: first_site) }

      let(:second_site) { create(:site, street: 'Front St', city: 'Toronto') }
      let(:second_customer) { create(:customer, name: 'Tyler Brewer', email: 't.brewer@gmail.com', phone: '5556667777') }
      let!(:second_estimate) { create(:estimate, customer: second_customer, site: second_site) }

      let(:search_query) { '' }
      let(:params) { { q: search_query } }

      context 'for name' do
        let(:search_query) { 'Tyle' }

        it 'should return one estimate' do
          expect(parsed_response['estimates'].count).to eq(1)
          expect(parsed_response['estimates'].first['id']).to eq(second_estimate.id)
        end
      end

      context 'for email' do
        let(:search_query) { 'rob.st' }

        it 'should return one estimate' do
          expect(parsed_response['estimates'].count).to eq(1)
          expect(parsed_response['estimates'].first['id']).to eq(first_estimate.id)
        end
      end

      context 'for phone' do
        let(:search_query) { '55566' }

        it 'should return one estimate' do
          expect(parsed_response['estimates'].count).to eq(1)
          expect(parsed_response['estimates'].first['id']).to eq(second_estimate.id)
        end
      end

      context 'for city' do
        let(:search_query) { 'Kings' }

        it 'should return one estimate' do
          expect(parsed_response['estimates'].count).to eq(1)
          expect(parsed_response['estimates'].first['id']).to eq(first_estimate.id)
        end
      end

      context 'for street' do
        let(:search_query) { 'Front' }

        it 'should return one estimate' do
          expect(parsed_response['estimates'].count).to eq(1)
          expect(parsed_response['estimates'].first['id']).to eq(second_estimate.id)
        end
      end
    end

  end

  # describe "index" do
  #   before do
  #     get :index
  #   end

  #   it "renders index template" do
  #     should render_template(:index)
  #   end

  #   it "assigns estimates list" do
  #     expect(assigns(:estimates)).not_to be_nil
  #   end

  #   context "with no estimates" do
  #     it "sets empty estimate list" do
  #       expect(assigns(:estimates).count).to eq(0)
  #     end
  #   end

  #   context "with estimate" do
  #     let!(:estimate) { create(:estimate) }

  #     it "sets single element estimate list" do
  #       expect(assigns(:estimates).count).to eq(1)
  #     end

  #     it "includes estimate" do
  #       expect(assigns(:estimates)).to include(estimate)
  #     end
  #   end

  #   context "with unrequested estimate" do
  #     let!(:estimate) { create(:estimate) }
  #     let!(:unrequested) { create(:estimate, submission_completed: false) }

  #     it "sets single element estimate list" do
  #       expect(assigns(:estimates).count).to eq(1)
  #     end

  #     it "screens out unrequested estimate" do
  #       expect(assigns(:estimates)).to include(estimate)
  #       expect(assigns(:estimates)).not_to include(unrequested)
  #     end
  #   end
  # end

  describe "new" do
    it "renders new template" do
      get :new
      should render_template(:new)
    end

    it "assigns customer" do
      get :new
      expect(assigns(:customer)).not_to be_nil
    end

    context "without customer_id" do
      it "sets new customer" do
        get :new
        expect(assigns(:customer).id).to be_nil
      end
    end

    context "with customer_id" do
      let!(:customer) { create(:customer) }

      it "sets existing customer" do
        get :new, { customer_id: customer.id }
        expect(assigns(:customer).id).to eq(customer.id)
      end
    end
  end

  describe "show" do
    let!(:estimate) { create(:estimate) } 

    it "renders show template" do
      get :show, { id: estimate.id }
      should render_template(:show)
    end

    it "sets estimate" do
      get :show, { id: estimate.id }
      expect(assigns(:estimate)).to eq(estimate)
    end
  end

  describe "update" do
    let!(:estimate) { create(:estimate) }
    
    it "updates estimate attributes" do
      expect(estimate.work_date).to be_nil
      patch :update, { id: estimate.id, estimate: { work_date: Date.today }}
      expect(estimate.reload.work_date).to eq(Date.today)
    end

    context "with unknown status set" do
      it "sets unknown" do
        expect(estimate.is_unknown).to eq(false)
        patch :update, { id: estimate.id, estimate: { is_unknown: true }}
        expect(estimate.reload.is_unknown).to eq(true)
      end
    end

    context "with no unknown status" do
      it "remains false if already false" do
        estimate.update(is_unknown: false)
        patch :update, { id: estimate.id, estimate: { work_date: Date.today }}
        expect(estimate.reload.is_unknown).to eq(false)
      end

      it "resets to false if already true" do
        estimate.update(is_unknown: true)
        patch :update, { id: estimate.id, estimate: { work_date: Date.today }}
        expect(estimate.reload.is_unknown).to eq(false)
      end
    end
  end

  describe "create" do

  end
end
