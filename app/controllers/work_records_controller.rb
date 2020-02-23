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
    @work_record.hours = work_record_params[:hours]

    if @work_record.save
      redirect_to arborist_path(current_user)
    else
      render :new
    end
  end

  private

    def work_record_params
      params.require(:work_record).permit(:date, :hours)
    end
end
