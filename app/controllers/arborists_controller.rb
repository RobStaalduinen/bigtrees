class ArboristsController < ApplicationController
  before_action :signed_in_admin, except: [ :show ]
  layout 'admin_material'
  
  def index
    @arborists = Arborist.all
  end

  def show
    @arborist = Arborist.find(params[:id])
  end

  def new 
    @arborist = Arborist.new
  end
  
  def edit
    @arborist = Arborist.find(params[:id])
  end

  def create
    @arborist = Arborist.new(arborist_params)

    if @arborist.save
      redirect_to arborist_path(@arborist)
    else
      render :new
    end
  end

  def update
    @arborist = Arborist.find(params[:id])
    @arborist.update(arborist_params)
    redirect_to estimates_path
  end

  def destroy
    @arborist = Arborist.find(params[:id])
    @arborist.destroy
    redirect_to estimates_path
  end

  private

    def arborist_params
      params.require(:arborist).permit(:name, :certification, :email, :phone_number, :password, :password_confirmation)
    end
    

end
