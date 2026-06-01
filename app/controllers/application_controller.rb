class ApplicationController < ActionController::Base
  include UserHelper
  include Pundit::Authorization

  # TEMPORARY (added 2026-06-01): CSRF protection disabled while we migrate from
  # cookie-based auth to header-based token auth, which removes the need for it.
  # SameSite=Lax (Rails 8 default) still blocks cross-site POST/PUT/DELETE since
  # the auth cookie isn't sent on those. Residual gaps: state-changing GETs and
  # same-site (sibling-subdomain) XSS. REMOVE this line once the auth migration
  # lands and header auth is the only path. See .sdd/ENG-9/spec.md
  skip_forgery_protection

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
