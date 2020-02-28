module Reports
  class Hours

    def initialize(spreadsheet_writer:, work_records: WorkRecord.all)
      raise ArgumentError unless spreadsheet_writer.present?

      @spreadsheet_writer = spreadsheet_writer
      @work_records = work_records
    end

    def create_spreadsheet
      export_days
      export_weeks
      export_months
      export_years
      @spreadsheet_writer.save

      return @spreadsheet_writer.destination
    end

    private

      def export_days
        @spreadsheet_writer.set_worksheet(0)
        dates = @work_records.pluck(:date).uniq.sort
        write_header(dates)
        write_arborist_daily_hours(dates)
      end

      def export_weeks
        @spreadsheet_writer.set_worksheet(1)
        weeks = @work_records.by_week.map {|week, _| week }
        write_header(weeks)
        write_arborist_weekly_hours(weeks)
      end

      def export_months
        @spreadsheet_writer.set_worksheet(2)
        months = @work_records.by_month.map {|month, _| month }
        write_header(months)
        write_arborist_monthly_hours(months)
      end

      def export_years
        @spreadsheet_writer.set_worksheet(3)
        years = @work_records.by_year.map {|year, _| year }
        write_header(years)
        write_arborist_yearly_hours(years)
      end

      def write_header(dates)
        @spreadsheet_writer.write_row(0, [nil] + dates)
      end

      def write_arborist_rows
        Arborist.all.order('id ASC').each_with_index do |arborist, row|
          @spreadsheet_writer[row+1, 0] = arborist.name
          yield(arborist, row)
        end 
      end

      def write_arborist_daily_hours(dates)
        write_arborist_rows do |arborist, row|
          write_arborist_row_for_metric(arborist.work_records.by_date, dates, row)
        end
      end

      def write_arborist_weekly_hours(weeks)
        write_arborist_rows do |arborist, row|
          write_arborist_row_for_metric(arborist.work_records.by_week, weeks, row)
        end
      end

      def write_arborist_monthly_hours(months)
        write_arborist_rows do |arborist, row|
          write_arborist_row_for_metric(arborist.work_records.by_month, months, row)
        end
      end
      
      def write_arborist_yearly_hours(years)
        write_arborist_rows do |arborist, row|
          write_arborist_row_for_metric(arborist.work_records.by_year, years, row)
        end
      end

      def write_arborist_row_for_metric(grouped_hours, dates, row)
        dates.each_with_index do |date, column|
          records = grouped_hours.select { |record_date, _| record_date == date }.last
          @spreadsheet_writer[row+1, column+1] = records[1].sum(&:hours) if records.present?
        end
      end

  end
end
