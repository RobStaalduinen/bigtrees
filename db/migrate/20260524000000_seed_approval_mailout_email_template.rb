class SeedApprovalMailoutEmailTemplate < ActiveRecord::Migration[6.0]
  def up
    Organization.find_each do |org|
      OrganizationCreator::EmailTemplateCreator.new(org).seed_email_templates
    end
  end

  def down
    EmailTemplate.where(key: 'approval_mailout').destroy_all
  end
end
