class ArboristsController < ApplicationController
  layout 'admin'
  
  def index
    @arborists = Arborist.all
  end

  def new 

  end
  
  def edit
    @arborist = Arborist.find(params[:id])
  end

  def create
    @arborist = Arborist.create(arborist_params)

    redirect_to estimates_path
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
      params.require(:arborist).permit(:name, :certification, :email, :phone_number, :password)
    end
    

end
