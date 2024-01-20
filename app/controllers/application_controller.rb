class ApplicationController < ActionController::Base
  include UserHelper
  include Pundit

  rescue_from CanCan::AccessDenied do |exception|
    Sentry.capture_exception(exception)

    respond_to do |format|
      format.html { :redirect_unauthorized }
      format.json { render json: { error: 'Unauthorized'}, status: :unauthorized }
    end
  end

  before_action :redirect_if_old
  before_action :set_organization

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

  def current_organization
    current_user.organizations.first
  end

  def set_organization
    OrganizationContext.set_current_organization(request, current_user)
  end
end
