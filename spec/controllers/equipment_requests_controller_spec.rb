describe EquipmentRequestsController do
  let!(:user) { create(:admin) }

  before do
    log_in_user(user)
  end
  
  describe "index" do
    before do
      get :index
    end

    context "for employee" do
      let!(:user) { create(:employee) }

      it "is restricted" do
        should redirect_to arborists_path(user)
      end
    end

    it "renders index template" do
      should render_template :index
    end

    context "without equipment requests" do
      it "assigns empty list" do
        expect(assigns(:equipment_requests).count).to eq(0)
      end
    end

    context "with equipment requests" do
      let!(:first_request) { create(:equipment_request) }
      let!(:second_request) { create(:equipment_request) }

      it "assigns equipment requests to list" do
        expect(assigns(:equipment_requests).count).to eq(2)
      end
    end

  end

  describe "show" do
    let!(:equipment_request) { create(:equipment_request) }

    context "for employee" do
      let!(:user) { create(:employee) }

      it "is restricted" do
        get :show, { id: equipment_request.id }
        should redirect_to arborists_path(user)
      end
    end

    it "renders show template" do
      get :show, { id: equipment_request.id }
      should render_template :show
    end

    it "sets equipment request" do
      get :show, { id: equipment_request.id }
      expect(assigns(:equipment_request)).not_to be_nil
      expect(assigns(:equipment_request).id).to eq(equipment_request.id)
    end
  end

  describe "new" do
    it "renders new template" do
      get :new
      should render_template(:new)
    end

    it "sets a new equipment request" do
      get :new
      expect(assigns(:equipment_request)).not_to be_nil
      expect(assigns(:equipment_request).id).to be_nil
    end
  end

  describe "create" do
    context "with invalid attributes" do
      let!(:attributes) { { equipment_request: { description: "test" }} }

      it "does not create a new equipment request" do
        expect {
          post :create, attributes
        }.to change(EquipmentRequest, :count).by(0)
      end

      it "re-renders new template" do
        post :create, attributes
        should render_template(:new)
      end

      it "sets a flash error message" do
        post :create, attributes
        expect(flash.now[:error]).not_to be_nil
      end
    end

    context "with valid attributes" do
      let!(:attributes) { { equipment_request: attributes_for(:equipment_request) } }

      it "creates a new equipment request" do
        expect{
          post :create, attributes
        }.to change(EquipmentRequest, :count).by(1)
      end

      it "equipment request has required attributes" do
        post :create, attributes
        expect(EquipmentRequest.last.category).to eq(attributes[:equipment_request][:category])
        expect(EquipmentRequest.last.description).to eq(attributes[:equipment_request][:description])
      end

      it "assigns request to logged in user" do
        post :create, attributes
        expect(EquipmentRequest.last.arborist).to eq(user)
      end

      it "redirects to new" do
        post :create, attributes
        should redirect_to new_equipment_request_path
      end

      it "sets a flash success message" do
        post :create, attributes
        expect(flash[:success]).not_to be_nil
      end
    end
  end

  describe "resolve" do
    context "for employee" do
      let!(:user) { create(:employee) }

      it "is restricted" do
        post :resolve, { equipment_request_id: 1 }
        should redirect_to arborists_path(user)
      end
    end

    context "for resolveable request" do
      let!(:equipment_request) { create(:equipment_request, state: :submitted) }

      it "redirects to requests index" do
        post :resolve, { equipment_request_id: equipment_request.id }
        should redirect_to equipment_requests_path
      end

      it "resolves request" do
        expect(equipment_request.submitted?).to eq(true)
        post :resolve, { equipment_request_id: equipment_request.id }
        expect(equipment_request.reload.resolved?).to eq(true) 
      end
    end

    context "for already resolved request" do
      let!(:equipment_request) { create(:equipment_request, state: :resolved) }

      it "redirects to requests index" do
        post :resolve, { equipment_request_id: equipment_request.id }
        should redirect_to equipment_requests_path
      end

      it "does not change state" do
        expect(equipment_request.resolved?).to eq(true)
        post :resolve, { equipment_request_id: equipment_request.id }
        expect(equipment_request.reload.resolved?).to eq(true) 
      end
    end

  end

end
