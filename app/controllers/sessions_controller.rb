class SessionsController < ApplicationController
  def new
    @organization = Organization.first

    redirect_to '/admin/estimates' if signed_in?
  end

  def authenticate
    if current_user
      response = AuthSerializer.new(current_user).serializable_hash.merge(
        { logged_in: true, admin: current_user.admin?, user_id: current_user.id, default_organization_id: current_user.organizations.first.id, organization_count: policy_scope(Organization).count }
      )
      render json: response
    else
      render json: { logged_in: false, admin: false }
    end
  end

  def create
    @arborist = Arborist.find_by(email: params[:email])

    if @arborist && @arborist.authenticate(params[:password]) && @arborist.has_memberships?
      sign_in(@arborist)
      if @arborist.admin?
        redirect_to '/admin/estimates'
      else
        redirect_to "/admin/users/#{@arborist.id}"
      end
    else
      flash[:error] = "Invalid email/password"
      redirect_to login_path
    end
  end

  def destroy
    sign_out

    respond_to do |format|
      format.html { redirect_to login_path }
      format.json { render json: {}, status: :ok }
    end
  end

end
