require "cancan/matchers"

describe Arborist do
  
  describe "abilities" do
    
    let!(:employee) { create(:employee) }
    let!(:admin) { create(:arborist) }

    context "employee" do
      subject(:ability) { Ability.new(employee) }
      
      it { is_expected.not_to be_able_to(:manage, Arborist) }
      it { is_expected.not_to be_able_to(:read, Arborist.new) }
      it { is_expected.to be_able_to(:read, employee) }
      it { is_expected.not_to be_able_to(:read, admin) }

    end

    context "admin" do
      subject(:ability) { Ability.new(admin) }
      
      it { is_expected.to be_able_to(:manage, Arborist) }
      it { is_expected.to be_able_to(:read, Arborist.new) }
      it { is_expected.to be_able_to(:read, employee) }
      it { is_expected.to be_able_to(:read, admin) }
    end

  end

end
