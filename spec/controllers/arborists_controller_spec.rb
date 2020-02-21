describe ArboristsController do
  let!(:arborist) { create(:arborist) }

  before do
    log_in_user(arborist)
  end

  describe "non-admin" do
    let!(:arborist) { create(:employee) }

    describe "new" do
      it "redirects to show path" do
        get :new
        should redirect_to(arborist_path(arborist))
      end
    end
  end

  describe "new" do
    it "renders new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "show" do
    let!(:arborist) { create(:employee) }

    it "renders show template" do
      get :show, { id: arborist.id }
      expect(response).to render_template(:show)
    end

    it "sets the arborist variable" do
      get :show, { id: arborist.id }
      expect(assigns(:arborist)).not_to be_nil
    end
  end

  describe "create" do
    context "with invalid attributes" do
      let!(:attributes) { attributes_for(:invalid_arborist) }

      it "does not create an arborist" do
        expect{ 
          post :create, arborist: attributes
        }.to change(Arborist, :count).by(0)
      end

      it "re-renders new template" do
        post :create, arborist: attributes
        should render_template(:new)
      end
    end

    context "with valid attributes" do
      let!(:attributes) { attributes_for(:employee) }

      it "creates a new arborist" do
        expect{ 
          post :create, arborist: attributes
        }.to change(Arborist, :count).by(1)
      end

      it "redirects to arborist profile" do
        post :create, arborist: attributes
        should redirect_to(arborist_path(Arborist.last))
      end
    end
  end

  
end
