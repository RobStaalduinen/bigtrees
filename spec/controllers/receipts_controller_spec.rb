describe ReceiptsController do
  let(:admin) { create(:admin) }
  let(:arborist) { create(:employee) }

  describe 'index' do
    subject(:get_request) { get :index }
    let!(:first_receipt) { create(:receipt, arborist: admin) }
    let!(:second_receipt) { create(:receipt, arborist: arborist) }

    context 'arborist' do
      before { log_in_user(arborist) }

      it { should render_template :index }
      it { should assigns(:receipts) }

      it 'only assigns receipt for arborist' do
        get_request
        receipts = assigns(:receipts)
        expect(receipts.count).to eq(1)
        expect(receipts.first).to eq(second_receipt)
      end
    end
    
    context 'admin' do
      before { log_in_user(admin) }

      it { should render_template :index }
      it { should assigns(:receipts) }

      it 'assigns receipts for all arborists' do
        get_request
        receipts = assigns(:receipts)
        expect(receipts.count).to eq(2)
      end
    end
  end

  describe "#new" do
    subject(:get_request) { get :new }
    before { log_in_user(arborist) }
    
    it { should render_template :new }
    it { should assigns(:receipt) }

    context 'with available vehicles' do
      let!(:vehicle) { create(:vehicle) }

      it { should assigns(:vehicles) }
    end
  end

  describe '#show' do
    let(:receipt) { create(:receipt) }
    subject(:get_request) { get :show, { id: receipt.id } }
    before { log_in_user(arborist) }

    it { should render_template :show }
    
    it 'sets receipt' do
      get_request
      expect(assigns(:receipt)).to eq(receipt)
    end
  end 

  describe '#create' do
    subject(:post_request) { post :create, { receipt: attributes_for(:receipt) } }
    
    context 'employee' do
      before { log_in_user(arborist) }

      it { should redirect_to receipts_path }

      it 'creates an unapproved receipt' do
        expect{
          post_request
        }.to change(Receipt, :count).by(1)
        expect(Receipt.last.approved).to eq(false)
      end
    end

    context 'admin' do
      before { log_in_user(admin) }

      it 'automatically approves the receipt' do
        expect{
          post_request
        }.to change(Receipt, :count).by(1)
        expect(Receipt.last.approved).to eq(true)
      end

    end
  end

  describe '#approve' do
    let(:receipt) { create(:receipt) }
    subject (:post_request) { post :approve, { id: receipt.id } }

    context 'admin' do
      before { log_in_user(admin) }

      it { should redirect_to receipts_path }

      it 'sets receipt to approved' do
        post_request
        expect(receipt.reload.approved).to eq(true)
      end
    end

    context 'employee' do
      before { log_in_user(arborist) }

      it { should redirect_to arborist_path(arborist) }

      it 'does not change receipt status' do
        post_request
        expect(receipt.reload.approved).to eq(false)
      end
    end
    
  end

end
