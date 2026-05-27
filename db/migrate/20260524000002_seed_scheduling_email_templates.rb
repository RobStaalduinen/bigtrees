class SeedSchedulingEmailTemplates < ActiveRecord::Migration[6.0]
  def up
    EmailTemplate.reset_column_information

    Organization.find_each do |org|
      OrganizationCreator::EmailTemplateCreator.new(org).seed_email_templates
    end
  end

  def down
    EmailTemplate.where(key: ['48_hour_notice', 'crew_on_the_way']).destroy_all
  end
end
