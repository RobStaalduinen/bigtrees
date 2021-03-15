class ArboristsController < ApplicationController
  before_action :signed_in_admin, except: [ :index, :show ]
  layout 'admin_material'

  def index
    @arborists = Arborist.real

    respond_to do |format|
      format.html
      format.json { render json: @arborists }
    end
  end

  def show
    @arborist = Arborist.find(params[:id])
    authorize! :read, @arborist

    respond_to do |format|
      format.html do
        @recent_work = @arborist.recent_work
        @documents = @arborist.documents
      end
      format.json do
        render json: @arborist
      end
    end
  end

  def new
    authorize! :manage, Arborist
    @arborist = Arborist.new
  end

  def edit
    authorize! :manage, Arborist
    @arborist = Arborist.find(params[:id])
  end

  def create
    authorize! :manage, Arborist
    @arborist = Arborist.new(arborist_params)

    if @arborist.save
      redirect_to arborist_path(@arborist)
    else
      redirect_to new_arborist_path
    end
  end

  def update
    authorize! :manage, Arborist
    @arborist = Arborist.find(params[:id])
    @arborist.update(arborist_params)
    redirect_to arborist_path(@arborist)
  end

  def destroy
    @arborist = Arborist.find(params[:id])
    @arborist.destroy
    redirect_to arborists_path
  end

  private

    def arborist_params
      params.require(:arborist).permit(:name, :certification, :email, :phone_number, :hourly_rate, :password, :password_confirmation, :can_manage_estimates)
    end


end
