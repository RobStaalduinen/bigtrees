describe ExpirationsController do
  let!(:arborist) { create(:admin) }
  let!(:vehicle) { create(:vehicle) }

  before do
    log_in_user(arborist)
  end

  describe "Auth" do
    context "for employee" do
      let!(:arborist) { create(:employee) }

      it "redirects new" do
        get :new
        should redirect_to(arborist_path(arborist))
      end

      it "redirects edit" do
        get :edit
        should redirect_to(arborist_path(arborist))
      end
    end
    
  end

  describe "new" do
    it "renders new template" do
      get :new
      should render_template(:new)
    end

    it "sets new expiration" do
      get :new
      expect(assigns(:expiration)).not_to be_nil
      expect(assigns(:expiration).id).to eq(nil)
    end

    it "has nil vehicle" do
      get :new
      expect(assigns(:vehicle)).to be_nil
    end

    context "with vehicle id" do
      let!(:vehicle) { create(:vehicle) }
      
      it "sets vehicle" do
        get :new, { vehicle_id: vehicle.id }
        expect(assigns(:vehicle)).not_to be_nil
        expect(assigns(:vehicle).id).to eq(vehicle.id)
      end
    end
  end

  describe "create" do
    context "with invalid attributes" do
      let!(:invalid_attributes) { { expiration: { name: "Wrong"} } }

      it "does not create a new expiration" do
        expect{
          post :create, invalid_attributes
        }.to change(Expiration, :count).by(0)
      end

      it "re-renders new template" do
        post :create, invalid_attributes
        should render_template :new
      end

      it "sets flash error message" do
        post :create, invalid_attributes
        expect(flash[:error]).not_to be_nil
      end
    end

    context "with valid attributes" do
      let!(:vehicle) { create(:vehicle) }
      let!(:attributes) { { expiration: attributes_for(:expiration).merge({vehicle_id: vehicle.id}) } }

      it "creates a new expiration" do
        expect{
          post :create, attributes
        }.to change(Expiration, :count).by(1)
      end

      it "redirects to vehicles path" do
        post :create, attributes
        should redirect_to vehicles_path
      end
    end
  end

  describe "edit" do
    let!(:expiration) { create(:expiration) }

    it "renders edit template" do
      get :edit, { id: expiration.id }
      should render_template :edit
    end

    it "sets expiration" do
      get :edit, { id: expiration.id }
      expect(assigns(:expiration)).not_to be_nil
      expect(assigns(:expiration).id).to eq(expiration.id)
    end

    it "sets is_edit" do
      get :edit, { id: expiration.id }
      expect(assigns(:is_edit)).to eq(true)
    end
  end

  describe "update" do
    let!(:expiration) { create(:expiration) }

    it "updates date" do
      post :update, { id: expiration.id, expiration: { date: Date.today + 3.months }}
      expect(expiration.reload.date).to eq(Date.today + 3.months)
    end

    it "renders to vehicles_path" do
      post :update, { id: expiration.id, expiration: { date: Date.today + 3.months }}
      should redirect_to vehicles_path
    end
  end
end
