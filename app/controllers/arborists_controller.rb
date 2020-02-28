class ArboristsController < ApplicationController
  before_action :signed_in_admin, except: [ :show ]
  layout 'admin_material'
  
  def index
    authorize! :manage, Arborist
    @arborists = Arborist.all
  end

  def show
    @arborist = Arborist.find(params[:id])
    authorize! :read, @arborist
    @recent_work = @arborist.recent_work
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
      render :new
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
      params.require(:arborist).permit(:name, :certification, :email, :phone_number, :password, :password_confirmation)
    end
    

end
