describe PayoutsController do
  let!(:arborist) { create(:admin) }
  let!(:vehicle) { create(:vehicle) }

  before do
    log_in_user(arborist)
  end

  describe "index" do
    let!(:payout) { create(:payout) }

    it "renders index template" do
      get :index
      should render_template :index
    end

    it "sets payouts" do
      get :index
      expect(assigns(:payouts)).not_to be_nil
      expect(assigns(:payouts).count).to eq(1)
      expect(assigns(:payouts).last).to eq(payout)
    end
  end

  describe "new" do
    let!(:payout) { create(:payout) }
    let!(:first_work_record) { create(:work_record, payout: payout, date: Date.yesterday) }
    let!(:second_work_record) { create(:work_record, date: Date.yesterday) }
    
    it "sets work_records" do
      get :new
      expect(assigns(:work_records)).not_to be_nil
    end

    it "only includes unpaid work records" do
      get :new
      records = assigns(:work_records)
      expect(records).to include(second_work_record)
      expect(records).not_to include(first_work_record)
    end

    context "with date parameter" do
      let!(:third_work_record) { create(:work_record, date: Date.today)}

      it "sets work records on or before date" do
        get :new, { date: Date.yesterday }
        records = assigns(:work_records)
        expect(records).to include(second_work_record)
        expect(records).not_to include(third_work_record)
      end
    end
  end

  describe "create" do
    let!(:attributes) { attributes_for(:payout, date: Date.yesterday) }
    
    it "creates a new payout" do
      expect{ 
        post :create, { payout: attributes }
      }.to change(Payout, :count).by(1)
    end

    context "with single work record before date" do
      let!(:work_record) { create(:work_record, date: Date.yesterday - 1.day) }

      it "assigns work record" do
        post :create, { payout: attributes }
        expect(work_record.reload.payout).to eq(Payout.last)
      end
    end

    context "with work records before and after date" do
      let!(:first_work_record) { create(:work_record, date: Date.yesterday - 1.day) }
      let!(:second_work_record) { create(:work_record, date: Date.today) }

      it "only assigns work records before date" do
        post :create, { payout: attributes }
        expect(first_work_record.reload.payout).to eq(Payout.last)
        expect(second_work_record.reload.payout).to be_nil
      end
    end

    context "with paid work records before date" do
      let!(:payout) { create(:payout) }
      let!(:first_work_record) { create(:work_record, payout: payout, date: Date.yesterday) }
      let!(:second_work_record) { create(:work_record, date: Date.yesterday) }
      
      it "does not change their payout" do
        post :create, { payout: attributes }
        expect(payout).not_to eq(Payout.last)
        expect(first_work_record.reload.payout).to eq(payout)
        expect(second_work_record.reload.payout).to eq(Payout.last)
      end
    end
  end

  describe "show" do
    let!(:payout) { create(:payout) }

    it "sets payout" do
      get :show, { id: payout.id }
      expect(assigns(:payout)).to eq(payout)
    end

    it "renders show template" do
      get :show, { id: payout.id }
      should render_template :show
    end
  end

  describe "delete" do
    let!(:payout) { create(:payout) }

    it "deletes the payout" do
      expect{ 
        delete :destroy, { id: payout.id }
      }.to change(Payout, :count).by(-1)
    end
  end

end
