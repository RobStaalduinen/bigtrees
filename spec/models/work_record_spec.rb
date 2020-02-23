describe WorkRecord do
  
  describe "Scopes" do
    describe "for_month" do
      let!(:first) { create(:work_record, date: Date.today.last_month) }
      let!(:second) { create(:work_record, date: Date.today.end_of_month - 2.days) }
      let!(:third) { create(:work_record, date: Date.today.end_of_month - 5.days) }

      it "returns work records inside the month" do
        expect(WorkRecord.for_month(Date.today)).to include(second)
        expect(WorkRecord.for_month(Date.today)).to include(third)
      end

      it "does not include records outside the month" do
        expect(WorkRecord.for_month(Date.today)).not_to include(first)
      end

      it "returns records in order of date" do
        records = WorkRecord.for_month(Date.today)
        expect(records[0]).to eq(third)
        expect(records[1]).to eq(second)
      end
    end

  end
end
