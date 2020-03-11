describe VehiclesController do
  let!(:user) { create(:admin) }

  before do
    log_in_user(user)
  end

  describe "index" do
    before do
      get :index
    end

    it "renders index template" do
      should render_template(:index)
    end

    it "sets vehicles list" do
      expect(assigns(:vehicles)).not_to be_nil
    end

    context "without vehicles" do
      it "sets an empty vehicle list" do
        expect(assigns(:vehicles).count).to eq(0)
      end
    end

    context "with vehicles" do
      let!(:first_vehicle) { create(:vehicle) }
      let!(:second_vehicle) { create(:vehicle) }

      it "includes all vehicles" do
        expect(assigns(:vehicles).count).to eq(2)
        expect(assigns(:vehicles)).to include(first_vehicle)
        expect(assigns(:vehicles)).to include(second_vehicle)
      end
    end
  end
  
  describe "new" do
    it "renders new template" do
      get :new
      should render_template(:new)
    end

    it "sets new vehicle" do
      get :new
      expect(assigns(:vehicle)).not_to be_nil
      expect(assigns(:vehicle).id).to be_nil
    end
  end

  describe "show" do
    let!(:vehicle) { create(:vehicle) }
    let!(:equipment_request) { create(:equipment_request, vehicle: vehicle) }

    it "renders show template" do
      get :show, { id: vehicle.id }
      should render_template(:show)
    end

    it "sets vehicle" do
      get :show, { id: vehicle.id }
      expect(assigns(:vehicle)).not_to be_nil
      expect(assigns(:vehicle)).to eq(vehicle)
    end

    it "sets equipment requests" do
      get :show, { id: vehicle.id }
      expect(assigns(:equipment_requests)).not_to be_nil
      expect(assigns(:equipment_requests)).to include(equipment_request)
    end

  end

  describe "create" do
    let!(:attributes) { attributes_for(:vehicle) }

    it "creates a new vehicle" do
      expect{
        post :create, { vehicle: attributes }
      }.to change(Vehicle, :count).by(1)
    end

    it "redirects to vehicles page" do
      post :create, { vehicle: attributes }
      should redirect_to vehicle_path(Vehicle.last)
    end
  end

  describe "edit" do
    let!(:vehicle) { create(:vehicle) }

    it "renders edit template" do
      get :edit, { id: vehicle.id }
      should render_template(:edit)
    end

    it "sets vehicle" do
      get :edit, { id: vehicle.id }
      expect(assigns(:vehicle)).not_to be_nil
      expect(assigns(:vehicle)).to eq(vehicle)
    end

    it "sets is_edit flag" do
      get :edit, { id: vehicle.id }
      expect(assigns(:is_edit)).to eq(true)
    end
  end

  describe "update" do
    let!(:vehicle) { create(:vehicle) }
    let!(:attributes) { { name: "New Name"} }

    it "updates vehicle attributes" do
      post :update, { id: vehicle.id, vehicle: attributes }
      expect(vehicle.reload.name).to eq("New Name")
    end

    it "redirects to vehicle page" do
      post :update, { id: vehicle.id, vehicle: attributes }
      should redirect_to vehicle_path(vehicle)
    end
  end


end
