describe EquipmentRequest do

  describe "Validations" do
    it { should validate_presence_of(:category) }
    it { should validate_inclusion_of(:category).in_array(EquipmentRequest::CATEGORIES)}
    it { should validate_presence_of(:description) }
  end

  describe "State" do
    let!(:equipment_request) { create(:equipment_request) }

    describe "resolve" do
      it "transitions from submitted to resolved" do
        expect(equipment_request.state).to eq('submitted')
        equipment_request.resolve
        expect(equipment_request.state).to eq('resolved')
      end
    end
  end

end
