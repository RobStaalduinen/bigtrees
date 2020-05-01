class PayoutsController < ApplicationController
  before_action :signed_in_user

  layout 'admin_material'

  def index
    authorize! :manage, Arborist

    @payouts = Payout.all.includes(:work_records).order("date DESC")
  end

  def new
    authorize! :manage, Arborist
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    @work_records = WorkRecord.unpaid.includes(:arborist).before(@date)
    

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    authorize! :manage, Arborist
    
    payout = Payout.create(payout_params)

    WorkRecord.unpaid.before(payout.date).update_all(payout_id: payout.id)
    redirect_to payout_path(payout)
  end

  def show
    authorize! :manage, Arborist

    @payout = Payout.find(params[:id])
  end

  def destroy
    authorize! :manage, Arborist

    Payout.find(params[:id]).destroy

    redirect_to payouts_path
  end


  private
    def payout_params
      params.require(:payout).permit(:date)
    end
end
