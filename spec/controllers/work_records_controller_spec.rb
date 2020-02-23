describe WorkRecordsController do
  let!(:arborist) { create(:employee) }
  let!(:admin) { create(:arborist) }

  before do
    log_in_user(arborist)
  end

  describe "index" do
    let!(:first_record) { create(:work_record, arborist: admin) }
    let!(:second_record) { create(:work_record, arborist: arborist) }

    it "renders the index template" do
      get :index
      should render_template(:index)
    end

    it "assigns the work records relation" do
      get :index
      expect(assigns(:work_records)).not_to be_nil
    end

    context "for admin" do
      before do
        log_in_user(admin)
      end

      it "returns all work records" do
        get :index
        records = assigns(:work_records)
        expect(records).to include(first_record)
        expect(records).to include(second_record)
      end
    end

    context "for employee" do
      it "returns only their work records" do
        get :index
        records = assigns(:work_records)
        expect(records).not_to include(first_record)
        expect(records).to include(second_record)
      end
    end
  
  end

  describe "new" do
    describe "authentication" do
      context "logged out user" do
        before do
          log_out_users
        end
  
        it "redirects" do
          get :new
          should redirect_to login_path
        end
      end
    end

    it "renders the new template" do
      get :new
      should render_template(:new)
    end
    
    it "assigns a work record instance" do
      get :new
      expect(assigns(:work_record)).not_to be_nil
    end
  end

  describe "create" do
    context "with invalid attributes" do
      let!(:attributes) { attributes_for(:invalid_work_record) }

      it "does not create a new work record" do
        expect{
          post :create, { work_record: attributes }
        }.to change(WorkRecord, :count).by(0)
      end

      it "re-renders new template" do
        post :create, { work_record: attributes }
        should render_template(:new)
      end
    end

    context "with valid attributes" do
      let!(:attributes) { attributes_for(:work_record) }

      it "creates a new work record" do
        expect { 
          post :create, { work_record: attributes }
        }.to change(WorkRecord, :count).by(1)
      end

      it "should redirect to arborist path" do
        post :create, { work_record: attributes }
        should redirect_to arborist_path(arborist)
      end

      it "assigns work record to logged in arborist" do
        post :create, { work_record: attributes }
        expect(WorkRecord.last.arborist).to eq(arborist)
      end

      context "with existing record for date" do
        let!(:work_record) { create(:work_record, hours: 10, arborist: arborist) }

        it "does not create a new work record" do
          expect {
            post :create, { work_record: attributes }
          }.to change(WorkRecord, :count).by(0)
        end

        it "updates the number of hours" do
          expect(WorkRecord.last.hours).to eq(10)
          post :create, { work_record: attributes }
          expect(WorkRecord.last.hours).to eq(attributes[:hours])
        end
      end

    end

  end
end
