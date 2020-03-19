describe Expiration do
  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_inclusion_of(:name).in_array(Expiration::NAMES)}
  end
end
