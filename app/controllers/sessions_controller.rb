class SessionsController < ApplicationController
  layout 'admin_material'

  def new

  end

  def create
    @arborist = Arborist.find_by(email: params[:email])

    if @arborist && @arborist.authenticate(params[:password])
      sign_in(@arborist)
      redirect_to estimates_path
    else
      redirect_to login_path
    end
  end

end
