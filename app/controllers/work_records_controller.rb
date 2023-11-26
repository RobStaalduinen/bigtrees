class WorkRecordsController < AdminBaseController
  before_action :signed_in_user

  layout 'admin_material'

  def index
    @work_records = policy_scope(WorkRecord)
    if params[:arborist_id]
      @work_records = @work_records.where(arborist_id: params[:arborist_id])
    end

    @work_records = @work_records.includes(:arborist)

    # FILTERS
    @work_records = @work_records.where("date >= ?", params[:start_at] || Date.today - 10.days)
    @work_records = @work_records.where("date <= ?", params[:end_at] || Date.today)
  end

  def for_arborist
    @work_records = WorkRecord.where(arborist_id: params[:arborist_id]).includes(:arborist).order('date DESC')

    @work_records = @work_records.where("date >= ?", params[:start_at] || Date.today - 10.days)
    @work_records = @work_records.where("date <= ?", params[:end_at] || Date.today)

    render json: @work_records
  end

  def new
    @work_record = WorkRecord.new
  end

  def create
    @work_record = current_user.work_records.find_or_initialize_by(date: work_record_params[:date])
    @work_record.update(work_record_params)

    render json: @work_record
  end

  def update
    @work_record = WorkRecord.find(params[:id])
    @work_record.update(work_record_params)

    render json: { status: 200 }
  end

  def report
    authorize! :manage, Arborist

    report = Reports::Hours.new(
      work_records: policy_scope(WorkRecord),
      arborists: policy_scope(Arborist),
      spreadsheet_writer: Excel::Writer.new('hours_template.xlsx', 'big_tree_hours.xlsx')
    ).create_spreadsheet

    send_file report, filename: "BigTree__Hours.xlsx"
  end

  def summaries
    @work_records = policy_scope(WorkRecord) # current_user.admin? ? WorkRecord.all : current_user.work_records

    if params[:arborist_id]
      @work_records = @work_records.where(arborist_id: params[:arborist_id])
    end

    @work_records = @work_records.includes(:arborist)

    if params[:summary_type] == 'days'
      @work_records = @work_records.where('date >= ?', Date.today - 31.days).order('date DESC').group_by { |w| w.date.strftime('%Y-%m-%d') }
    elsif params[:summary_type] == 'weeks'
      @work_records = @work_records.where('date >= ?', Date.today - 90.days).order('date DESC').group_by { |w| w.week_number }
      if @work_records.keys.count > 52
        lowest_key = @work_records.keys.sort.first
        @work_records = @work_records.except(lowest_key)
      end
    elsif params[:summary_type] == 'months'
      @work_records = @work_records.where('date >= ?', (Date.today - 1.year).next_month.beginning_of_month).order('date DESC').group_by { |w| w.date.strftime("%m - %B") }
      if @work_records.keys.count > 12
        lowest_key = @work_records.keys.sort.first
        @work_records = @work_records.except(lowest_key)
      end
    else
      @work_records = @work_records.order('date DESC').group_by { |w| w.date.strftime("%Y") }
    end
  end

  private

    def work_record_params
      params.require(:work_record).permit(:date, :hours, :unpaid_hours, :start_at, :end_at)
    end
end
