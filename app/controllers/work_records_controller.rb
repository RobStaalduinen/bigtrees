class WorkRecordsController < AdminBaseController
  before_action :signed_in_user
  
  layout 'admin_material'

  def index
    @work_records = current_user.admin? ? WorkRecord.all : current_user.work_records
    @work_records = @work_records.includes(:arborist)

    # FILTERS
    @work_records = @work_records.where("date >= ?", params[:start_at] || Date.today - 10.days)
    @work_records = @work_records.where("date <= ?", params[:end_at] || Date.today)
  end
  
  def new
    @work_record = WorkRecord.new
  end

  def create
    @work_record = current_user.work_records.find_or_initialize_by(date: work_record_params[:date])
    @work_record.update(work_record_params)

    if @work_record.persisted?
      redirect_to arborist_path(current_user)
    else
      render new_work_record_path
    end
  end

  def update
    @work_record = WorkRecord.find(params[:id])
    @work_record.update(work_record_params)

    render json: { status: 200}
  end
  
  def report
    authorize! :manage, Arborist
    
    report = Reports::Hours.new(
      spreadsheet_writer: Excel::Writer.new('hours_template.xlsx', 'big_tree_hours.xlsx')
    ).create_spreadsheet

    send_file report, filename: "BigTree__Hours.xlsx"
  end

  def summaries
    @work_records = WorkRecord.all.includes(:arborist)

    if params[:summary_type] == 'days'
      @work_records = @work_records.where('date >= ?', Date.today - 31.days).order('date DESC').group_by { |w| w.date.strftime('%Y-%m-%d') }
    elsif params[:summary_type] == 'weeks'
      @work_records = @work_records.where('date >= ?', Date.today - 90.days).order('date DESC').group_by { |w| w.week_number }
      # remove lowest
      lowest_key = @work_records.keys.sort.first
      @work_records = @work_records.except(lowest_key)
    elsif params[:summary_type] == 'months'
      @work_records = @work_records.where('date >= ?', Date.today - 1.year).order('date DESC').group_by { |w| w.date.strftime("%m - %B") }
      lowest_key = @work_records.keys.sort.first
      @work_records = @work_records.except(lowest_key)
    else
      @work_records = @work_records.order('date DESC').group_by { |w| w.date.strftime("%Y") }
    end
  end

  private

    def work_record_params
      params.require(:work_record).permit(:date, :hours, :unpaid_hours, :start_at, :end_at)
    end
end
