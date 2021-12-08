class ArboristsController < ApplicationController
  before_action :signed_in_admin, except: [ :index, :show ]

  def index
    @arborists = Arborist.real

    render json: @arborists
  end

  def show
    @arborist = Arborist.find(params[:id])
    authorize! :read, @arborist

    render json: @arborist
  end

  def create
    authorize! :manage, Arborist
    @arborist = Arborist.new(arborist_params)
    @arborist.organization = current_user.organization
    @arborist.save

    render json: @arborist
  end

  def update
    authorize! :manage, Arborist
    @arborist = Arborist.find(params[:id])
    @arborist.update(arborist_params)

    render json: @arborist
  end

  def destroy
    @arborist = Arborist.find(params[:id])
    @arborist.destroy

    render json: @arborist
  end

  private

    def arborist_params
      params.require(:arborist).permit(
        :name, :certification, :email, :phone_number, :hourly_rate, :password, :password_confirmation, :role
      )
    end


end
