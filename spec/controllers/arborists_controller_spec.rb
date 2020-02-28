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

    describe "index" do
      it "redirects to show path" do
        get :index
        should redirect_to(arborist_path(arborist))
      end
    end

    describe "create" do
      it "redirects to show path" do
        post :create, arborist: {}
        should redirect_to(arborist_path(arborist))
      end
    end

    describe "update" do
      it "redirects to show path" do
        get :update, { id: arborist.id }
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

  describe "index" do
    it "renders index template" do
      get :index  
      expect(response).to render_template(:index)
    end

    it "sets the arborist list to all arborists" do
      get :index
      expect(assigns(:arborists)).not_to be_nil
      expect(assigns(:arborists).count).to eq(1)
    end
  end

  describe "show" do
    let!(:arborist) { create(:employee) }
    let!(:work_record) { create(:work_record, arborist: arborist, date: Date.today) }
    let!(:early_work_record) { create(:work_record, arborist: arborist, date: Date.today - 1.month) }

    it "renders show template" do
      get :show, { id: arborist.id }
      expect(response).to render_template(:show)
    end

    it "sets the arborist variable" do
      get :show, { id: arborist.id }
      expect(assigns(:arborist)).not_to be_nil
    end

    it "sets recent_work" do
      get :show, { id: arborist.id }
      expect(assigns(:recent_work)).not_to be_nil
    end

    it "includes this and last months work" do
      get :show, { id: arborist.id }  
      work = assigns(:recent_work)
      expect(work[:this_month]).not_to be_nil
      expect(work[:last_month]).not_to be_nil
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

  describe "update" do
    context "with valid attributes" do
      let!(:valid_attributes) {{ id: arborist.id, arborist: {certification: '111111' }}}

      it "does not create a new arborist" do
        expect {
          patch :update, valid_attributes
        }.to change(Arborist, :count).by(0)
      end

      it "changes the listed attributes" do
        initial_cert = arborist.certification
        patch :update, valid_attributes
        expect(arborist.reload.certification).not_to eq(initial_cert)
        expect(arborist.reload.certification).to eq('111111')
      end
    end

  end

  
end
