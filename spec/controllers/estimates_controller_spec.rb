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

  describe "index" do
    before do
      get :index
    end

    it "renders index template" do
      should render_template(:index)
    end

    it "assigns estimates list" do
      expect(assigns(:estimates)).not_to be_nil
    end

    context "with no estimates" do
      it "sets empty estimate list" do
        expect(assigns(:estimates).count).to eq(0)
      end
    end

    context "with estimate" do
      let!(:estimate) { create(:estimate) }

      it "sets single element estimate list" do
        expect(assigns(:estimates).count).to eq(1)
      end

      it "includes estimate" do
        expect(assigns(:estimates)).to include(estimate)
      end
    end

    context "with unrequested estimate" do
      let!(:estimate) { create(:estimate) }
      let!(:unrequested) { create(:estimate, submission_completed: false) }

      it "sets single element estimate list" do
        expect(assigns(:estimates).count).to eq(1)
      end

      it "screens out unrequested estimate" do
        expect(assigns(:estimates)).to include(estimate)
        expect(assigns(:estimates)).not_to include(unrequested)
      end
    end
  end

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
