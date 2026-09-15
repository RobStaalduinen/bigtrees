# frozen_string_literal: true

class OrganizationCreator
  class EmailInsertableCreator
    SCHEDULE_TEXT_OPTIONS = [
      { label: 'Reduced Costs', content: 'We will reduce the cost by 7% if we receive approval within 24 hours. Further, we guarantee completion within 10 business days.' },
      { label: 'Next few days', content: 'We could take care of your job as early as the next few days.' },
      { label: 'Within 1 week', content: 'We could take care of your job within the following week.' },
      { label: 'Within 2 weeks', content: 'We could take care of your job within the following two weeks.' },
      { label: 'More than 2 weeks', content: 'Due to a large number of active jobs, we could only schedule your job after a wait of two weeks.' }
    ].freeze

    def initialize(organization)
      @organization = organization
    end

    def seed_email_insertables
      create_schedule_text
    end

    private

    def create_schedule_text
      create_email_insertable('SCHEDULE_TEXT', 'Add Schedule Text', SCHEDULE_TEXT_OPTIONS)
    end

    def create_email_insertable(key, label, options)
      insertable = @organization.email_insertables.find_or_create_by!(key: key) do |record|
        record.label = label
      end

      options.each_with_index do |option, index|
        next if insertable.options.exists?(label: option[:label])

        insertable.options.create!(label: option[:label], content: option[:content], position: index)
      end

      insertable
    end
  end
end
