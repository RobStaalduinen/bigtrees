class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include UserHelper
  include Pundit

  # protect_from_forgery with: :null_session

  skip_before_action :verify_authenticity_token

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { :redirect_unauthorized }
      format.json { render json: { error: 'Unauthorized'}, status: :unauthorized }
    end
  end

  before_filter :redirect_if_old

  def redirect_if_old
    return unless Rails.env.production?

    url_list = ['thatsabigtree.ca', 'thatsabigtree.ca', 'bigtreeservices.com', 'bigtreecare.ca']
    if url_list.map { |u| u.include?(request.host) }.any?
      redirect_to "#{request.protocol}bigtreeservices.ca#{request.fullpath}", status: :moved_permanently
    end
  end

  def redirect_unauthorized
    redirect_to arborist_path(current_user)
  end


end
