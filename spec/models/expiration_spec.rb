describe Expiration do
  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:date) }
    it { should validate_inclusion_of(:name).in_array(Expiration::NAMES)}
  end

  describe "Instance methods" do
    describe "soon?" do
      context "within 30 days" do
        let!(:expiration) { create(:expiration, date: (Date.today + 30.days) - 1.day) }
        it "returns true" do
          expect(expiration.soon?).to eq(true)
        end
      end

      context "after 30 days" do
        let!(:expiration) { create(:expiration, date: (Date.today + 30.days) + 1.day) }
        it "returns false" do
          expect(expiration.soon?).to eq(false)
        end
      end
    end

    describe "expired?" do
      context "in future" do
        let!(:expiration) { create(:expiration, date: Date.today + 1.day) }

        it "returns false" do
          expect(expiration.expired?).to eq(false)
        end
      end

      context "in past" do
        let!(:expiration) { create(:expiration, date: Date.today - 1.day) }
        
        it "returns true" do
          expect(expiration.expired?).to eq(true)
        end
      end
    end
  end
end
