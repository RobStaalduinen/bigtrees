describe WorkRecord do
  describe "Callbacks" do
    describe "set_hourly_rate" do
      let!(:arborist) { create(:arborist, hourly_rate: 50.0) }
      
      it "takes hourly rate from arborist" do
        record = arborist.work_records.new({hours: 5.0, date: Date.today})
        expect(record.hourly_rate).to eq(nil)
        record.save!
        expect(record.hourly_rate).to eq(50.0)
      end
    end
  end

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

    describe "unpaid" do
      let!(:payout) { create(:payout) }
      let!(:first_work_record) { create(:work_record, payout: payout) }
      let!(:second_work_record) { create(:work_record) }
      
      it "only includes work records with no payout" do
        records = WorkRecord.unpaid
        expect(records).to include(second_work_record)
        expect(records).not_to include(first_work_record)
      end
    end
  end

  describe "Instance Methods" do
    describe "earnings" do
      context "without an hourly rate" do
        let!(:work_record) { create(:work_record) }
        it "returns zero" do
          work_record.hourly_rate = nil
          expect(work_record.earnings).to eq(0.0)
        end
      end

      context "with an hourly rate" do
        let!(:work_record) { create(:work_record, hours: 2) }
        it "returns hours times hourly rate" do
          work_record.hourly_rate = 10.0
          expect(work_record.earnings).to eq(20.0)
        end
      end
    end
  end
end
