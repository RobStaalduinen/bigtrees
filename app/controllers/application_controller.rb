class ApplicationController < ActionController::Base
  include UserHelper
  include Pundit

  before_action :redirect_if_old
  before_action :set_organization

  rescue_from StandardError do |e|
    Sentry.capture_exception(e)
    render json: { error: e.message }, status: :internal_server_error
  end

  def redirect_if_old
    return unless Rails.env.production?

    url_list = ['thatsabigtree.ca', 'thatsabigtree.ca', 'bigtreeservices.com']
    if url_list.map { |u| u.include?(request.host) }.any?
      redirect_to "#{request.protocol}admin.bigtreeservices.ca#{request.fullpath}", status: :moved_permanently
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
