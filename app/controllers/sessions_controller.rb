class SessionsController < ApplicationController
  layout 'admin_material'

  def new 
    redirect_to estimates_path if signed_in?
  end

  def create
    @arborist = Arborist.find_by(email: params[:email])

    if @arborist && @arborist.authenticate(params[:password]) && @arborist.active
      sign_in(@arborist)
      if @arborist.admin?
        redirect_to estimates_path
      else
        redirect_to arborists_path(@arborist)
      end
    else
      redirect_to login_path
    end
  end

  def destroy
    sign_out
    redirect_to login_path
  end

end
