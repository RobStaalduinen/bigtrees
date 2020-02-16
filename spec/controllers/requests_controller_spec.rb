describe RequestsController do
  
  describe "create" do
    context "with new customer" do
      let!(:attributes) { { estimate: attributes_for(:estimate), customer: attributes_for(:customer) } }
      
      it "creates a new estimate" do
        expect{ 
          post :create, attributes
        }.to change(Estimate, :count).by(1)
      end

      it "creates a new customer" do
        expect{ 
          post :create, attributes
        }.to change(Customer, :count).by(1)
      end
    end
    
    context "with existing customer" do
      let!(:customer) { create(:customer) }
      let!(:attributes) { { estimate: attributes_for(:estimate), customer: { id: customer.id, name: "New Name"} } }

      it "creates a new estimate" do
        expect{ 
          post :create, attributes
        }.to change(Estimate, :count).by(1)
      end

      it "does not create a new customer" do
        expect{ 
          post :create, attributes
        }.to change(Customer, :count).by(0)
      end

      it "assigns estimate to existing customer" do
        post :create, attributes
        expect(Estimate.last.customer).to eq(customer)
      end

      it "updates the customers info" do
        post :create, attributes
        expect(Customer.last.name).to eq("New Name")
      end
    end
  end
end
