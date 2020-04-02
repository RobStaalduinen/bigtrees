class WorkRecordsController < AdminBaseController
  before_action :signed_in_user
  
  layout 'admin_material'

  def index
    @work_records = current_user.admin? ? WorkRecord.all : current_user.work_records
    @work_records = @work_records.includes(:arborist)
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
  
  def report
    authorize! :manage, Arborist
    
    report = Reports::Hours.new(
      spreadsheet_writer: Excel::Writer.new('hours_template.xlsx', 'big_tree_hours.xlsx')
    ).create_spreadsheet

    send_file report, filename: "BigTree__Hours.xlsx"
  end

  private

    def work_record_params
      params.require(:work_record).permit(:date, :hours, :unpaid_hours, :start_at, :end_at)
    end
end
