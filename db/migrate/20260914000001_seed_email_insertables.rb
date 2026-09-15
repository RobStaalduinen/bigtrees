class SeedEmailInsertables < ActiveRecord::Migration[6.0]
  def up
    Organization.find_each do |organization|
      OrganizationCreator::EmailInsertableCreator.new(organization).seed_email_insertables
    end

    swap_placeholder('[ADDITIONAL_CONTENT_SLOT]', '[SCHEDULE_TEXT]')
  end

  def down
    swap_placeholder('[SCHEDULE_TEXT]', '[ADDITIONAL_CONTENT_SLOT]')

    EmailInsertable.where(key: 'SCHEDULE_TEXT').destroy_all
  end

  private

  def swap_placeholder(from, to)
    EmailTemplate.where(key: 'quote_mailout').find_each do |template|
      next unless template.content&.include?(from)

      template.update_columns(content: template.content.gsub(from, to))
    end
  end
end
