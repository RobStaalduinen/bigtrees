describe CostsController do
  let!(:estimate) { create(:estimate) }

  describe "create" do
    context "for positive costs" do
      it "creates a new cost" do
        expect{ 
          post :create, { estimate_id: estimate.id, costs: [attributes_for(:cost)] }
        }.to change(Cost, :count).by(1)
        expect(Cost.last.discount).to eq(false)
      end

      it "creates a cost with a postive amount" do
        post :create, { estimate_id: estimate.id, costs: [attributes_for(:cost)] }
        expect(Cost.last.amount).to eq(100.0)
      end
    end

    context "for discounts" do
      it "creates a new cost" do
        expect{ 
          post :create, { estimate_id: estimate.id, discount: true, costs: [attributes_for(:discount)] }
        }.to change(Cost, :count).by(1)
        expect(Cost.last.discount).to eq(true)
      end

      it "successfully sets with negative amount" do
        post :create, { estimate_id: estimate.id, discount: true, costs: [{ amount: -25.0 }] }
        expect(Cost.last.amount).to eq(-25.0)
      end

      it "defaults a positive amount to negative" do
        post :create, { estimate_id: estimate.id, discount: true, costs: [{ amount: 25.0 }] }
        expect(Cost.last.amount).to eq(-25.0)
      end
    end
  end

  describe "update" do
    context "for positive costs" do
      context "with no existing costs" do
        it "creates a new cost" do
          expect{ 
            post :update, { estimate_id: estimate.id, costs: [attributes_for(:cost)] }
          }.to change(Cost, :count).by(1)
          expect(Cost.last.discount).to eq(false)
        end
      end


      context "with existing costs" do
        let!(:cost) { create(:cost, estimate: estimate) }

        it "deletes old cost" do
          post :update, { estimate_id: estimate.id, costs: [attributes_for(:cost)] }
          expect(Cost.count).to eq(1)
          expect(Cost.last.id).not_to eq(cost.id)
        end

      end

      context "with existing costs and discounts" do
        let!(:cost) { create(:cost, estimate: estimate) }
        let!(:discount) { create(:discount, estimate: estimate) }

        it "does not delete old discount" do
          post :update, { estimate_id: estimate.id, costs: [attributes_for(:cost)] }
          expect(Cost.count).to eq(2)
          expect(Cost.discount.last.id).to eq(discount.id)
        end
      end
    end

    context "for discounts" do
      context "with no existing costs" do
        it "creates a new cost" do
          expect{ 
            post :update, { estimate_id: estimate.id, discount: true, costs: [attributes_for(:cost)] }
          }.to change(Cost, :count).by(1)
          expect(Cost.last.discount).to eq(true)
        end
      end


      context "with existing discounts" do
        let!(:discount) { create(:discount, estimate: estimate) }

        it "deletes old discount" do
          post :update, { estimate_id: estimate.id, discount: true, costs: [attributes_for(:cost)] }
          expect(Cost.count).to eq(1)
          expect(Cost.last.id).not_to eq(discount.id)
        end
      end

      context "with existing costs and discounts" do
        let!(:cost) { create(:cost, estimate: estimate) }
        let!(:discount) { create(:discount, estimate: estimate) }

        it "does not delete old cost" do
          post :update, { estimate_id: estimate.id, discount: true, costs: [attributes_for(:cost)] }
          expect(Cost.count).to eq(2)
          expect(Cost.charge.last.id).to eq(cost.id)
        end
      end
    end
  end
end
