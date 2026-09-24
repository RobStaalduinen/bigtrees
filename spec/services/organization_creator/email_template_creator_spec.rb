require 'rails_helper'

RSpec.describe OrganizationCreator::EmailTemplateCreator do
  let(:organization) { create(:organization) }
  subject(:creator) { described_class.new(organization) }

  describe '#seed_email_templates' do
    it 'creates exactly 9 templates with the expected keys' do
      expect { creator.seed_email_templates }.to change(EmailTemplate, :count).by(9)
      keys = organization.email_templates.pluck(:key)
      expect(keys).to contain_exactly(
        'quote_mailout', 'invoice_mailout', 'receipt_mailout',
        'no_response', 'image_request', 'approval_mailout',
        '48_hour_notice', 'crew_on_the_way', 'job_progress'
      )
    end

    it 'stores the approval_mailout subject literally with the placeholder' do
      creator.seed_email_templates
      template = organization.email_templates.find_by(key: 'approval_mailout')
      expect(template.subject).to eq('Your [ORGANIZATION_NAME] Job')
    end

    it 'files every template under the workflow step it is sent from' do
      creator.seed_email_templates

      expect(organization.email_templates.pluck(:key, :category)).to contain_exactly(
        ['quote_mailout', 'quote'],
        ['no_response', 'followup'],
        ['image_request', 'followup'],
        ['approval_mailout', 'approval'],
        ['48_hour_notice', 'scheduling'],
        ['crew_on_the_way', 'scheduling'],
        ['job_progress', 'job_progress'],
        ['invoice_mailout', 'invoice'],
        ['receipt_mailout', 'receipt']
      )
    end

    it 'seeds only categories the model recognises' do
      creator.seed_email_templates

      expect(organization.email_templates.pluck(:category).uniq - EmailTemplate::CATEGORIES).to be_empty
    end

    it 'seeds every template the workflow sends by key' do
      creator.seed_email_templates

      expect(organization.email_templates.pluck(:key)).to match_array(EmailTemplate::SYSTEM_KEYS)
    end

    it 'is idempotent — running twice results in 9 templates, not 18' do
      creator.seed_email_templates
      expect { creator.seed_email_templates }.not_to change(EmailTemplate, :count)
      expect(organization.email_templates.count).to eq(9)
    end

    it 'does not overwrite existing template content on re-run' do
      organization.email_templates.create!(
        key: 'approval_mailout',
        subject: 'Custom Subject',
        content: 'Custom content',
        category: 'approval'
      )
      creator.seed_email_templates
      template = organization.email_templates.find_by(key: 'approval_mailout')
      expect(template.subject).to eq('Custom Subject')
      expect(template.content).to eq('Custom content')
    end

    it 'inserts missing templates without touching existing ones' do
      existing = organization.email_templates.create!(
        key: 'quote_mailout',
        subject: 'Arborist Subject',
        content: 'Arborist content',
        category: 'quote'
      )
      expect { creator.seed_email_templates }.to change(EmailTemplate, :count).by(8)
      existing.reload
      expect(existing.subject).to eq('Arborist Subject')
      expect(existing.content).to eq('Arborist content')
    end
  end
end
