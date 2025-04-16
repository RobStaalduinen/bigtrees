class ArboristsController < ApplicationController
  before_action :signed_in_user

  def index
    @arborists = OrganizationContext.current_organization.arborists.real.active

    @arborists = filter_arborists(@arborists)

    render json: @arborists
  end

  def show
    authorize Arborist, :show?
    @arborist = policy_scope(Arborist).find(params[:id])

    render json: @arborist
  end

  def create
    authorize Arborist, :create?

    arborist = Arborist.find_or_initialize_by(email: params[:arborist][:email])

    is_existing = arborist.persisted? && arborist.has_memberships?

    if is_existing
      if OrganizationMembership.where(organization: OrganizationContext.current_organization, arborist: arborist).any?
        render json: { code: 'existing-arborist' }, status: 400
        return
      end

      arborist.update(arborist_update_params)

      membership = OrganizationMembership.create(
        organization: OrganizationContext.current_organization,
        arborist: arborist,
        hourly_rate: params[:arborist][:hourly_rate]
      )

      ArboristMailer.existing_arborist_mailout(arborist, membership).deliver_now

      render json: arborist, status: :ok, meta: { existing_user: true }
    else
      arborist.update(arborist_create_params)

      initial_password = arborist.generate_initial_password

      membership = OrganizationMembership.create(
        organization: OrganizationContext.current_organization,
        arborist: arborist,
        hourly_rate: params[:arborist][:hourly_rate]
      )

      ArboristMailer.new_arborist_mailout(arborist, membership, initial_password).deliver_now

      render json: arborist, status: :ok, meta: { existing_user: false }
    end
  end

  def update
    authorize Arborist, :update?
    @arborist = Arborist.find(params[:id])
    @arborist.update(arborist_update_params)
    @arborist.current_membership.update(hourly_rate: params[:arborist][:hourly_rate])

    render json: @arborist
  end

  def update_password
    authorize Arborist, :update?

    @arborist = policy_scope(Arborist).find(params[:arborist_id])
    @arborist.update(arborist_password_params)

    render json: @arborist
  end

  def destroy
    @arborist = Arborist.find(params[:id])

    membership = OrganizationMembership.find_by(arborist_id: @arborist.id, organization_id: OrganizationContext.current_organization.id)

    membership.destroy

    render json: {}, status: :ok
  end

  def filter_arborists(arborists)
    if params[:role]
      arborists = arborists.where(role: params[:role])
    end

    if params[:crew_member]
      arborists = arborists.where.not(role: 'mechanic').where.not(email: %w[thearn@bigislandgroup.ca rob.staalduinen@gmail.com])
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
        :name, :email, :phone_number, :role
      )
    end

    def arborist_password_params
      params.require(:arborist).permit(:password, :password_confirmation)
    end


end
