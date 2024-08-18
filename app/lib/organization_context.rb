# frozen_string_literal: true

class OrganizationContext
  def self.set_current_organization(request, current_user)
    header_org_id = request.headers['HTTP_X_ORGANIZATION_ID']

    return unless current_user

    header_org = Organization.find(header_org_id) if header_org_id
    @@current_organization = header_org.present? ? header_org : current_user.organizations.first
  end

  def self.current_organization
    @@current_organization
  end
end
