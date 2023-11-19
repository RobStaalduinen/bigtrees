# frozen_string_literal: true

class OrganizationContext
  def self.set_current_organization(request, current_user)
    header_org_id = request.headers['HTTP_ORGANIZATION_ID']
    if(current_user.role == 'super_admin')
      header_org = Organization.find(header_org_id) if header_org_id

      @@current_organization = header_org.present? ? header_org : current_user.organization
    else
      @@current_organization = current_user.organization
    end
  end

  def self.get_current_organization
    @@current_organization
  end
end
