class SessionsController < ApplicationController
  layout 'admin_material'

  def new
    redirect_to '/admin/estimates' if signed_in?
  end

  def authenticate
    if current_user
      render json: { logged_in: true, admin: current_user.admin?, user_id: current_user.id, can_manage_estimates: current_user.can_manage_estimates }
    else
      render json: { logged_in: false, admin: false }
    end
  end

  def create
    @arborist = Arborist.find_by(email: params[:email])

    if @arborist && @arborist.authenticate(params[:password]) && @arborist.active
      sign_in(@arborist)
      if @arborist.admin?
        redirect_to '/admin/estimates'
      else
        redirect_to arborist_path(@arborist)
      end
    else
      flash[:error] = "Invalid email/password"
      redirect_to login_path
    end
  end

  def destroy
    sign_out
    redirect_to login_path
  end

end
