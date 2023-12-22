class ArboristsController < ApplicationController
  before_action :signed_in_admin, except: [ :index, :show ]

  def index
    @arborists = OrganizationContext.current_organization.arborists.real

    @arborists = filter_arborists(@arborists)

    render json: @arborists
  end

  def show
    @arborist = Arborist.find(params[:id])
    authorize! :read, @arborist

    render json: @arborist
  end

  def create
    authorize! :manage, Arborist
    # @arborist = OrganizationContext.current_organization.arborists.new(arborist_params)
    @arborist = Arborist.find_or_initialize_by(email: params[:arborist][:email])

    is_existing = @arborist.persisted?

    if is_existing
      @arborist.update(arborist_update_params)
    else
      @arborist.update(arborist_create_params)
    end

    OrganizationMembership.create(
      organization: OrganizationContext.current_organization,
      arborist: @arborist,
      hourly_rate: params[:arborist][:hourly_rate]
    )

    if is_existing
      render json: @arborist, status: 201
    else
      render json: @arborist, status: 200
    end
  end

  def update
    authorize! :manage, Arborist
    @arborist = Arborist.find(params[:id])
    @arborist.update(arborist_update_params)
    @arborist.current_membership.update(hourly_rate: params[:arborist][:hourly_rate])

    render json: @arborist
  end

  def destroy
    @arborist = Arborist.find(params[:id])
    @arborist.destroy

    render json: @arborist
  end

  def filter_arborists(arborists)
    if params[:role]
      arborists = arborists.where(role: params[:role])
    end

    arborists
  end

  private

    def arborist_create_params
      params.require(:arborist).permit(
        :name, :email, :phone_number, :password, :password_confirmation, :role
      )
    end

    def arborist_update_params
      params.require(:arborist).permit(
        :name, :email, :phone_number
      )
    end


end
