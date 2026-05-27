class SeedSchedulingEmailTemplates < ActiveRecord::Migration[6.0]
  def up
    unless column_exists?(:email_templates, :category)
      add_column :email_templates, :category, :string, default: 'default', null: false
    end

    unless index_exists?(:email_templates, :category)
      add_index :email_templates, :category
    end

    EmailTemplate.reset_column_information

    Organization.find_each do |org|
      OrganizationCreator::EmailTemplateCreator.new(org).seed_email_templates
    end
  end

  def down
    EmailTemplate.where(key: ['48_hour_notice', 'crew_on_the_way']).destroy_all
  end
end
