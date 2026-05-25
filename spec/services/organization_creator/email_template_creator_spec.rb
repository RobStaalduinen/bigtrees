require 'rails_helper'

RSpec.describe OrganizationCreator::EmailTemplateCreator do
  let(:organization) { create(:organization) }
  subject(:creator) { described_class.new(organization) }

  describe '#seed_email_templates' do
    it 'creates exactly 8 templates with the expected keys' do
      expect { creator.seed_email_templates }.to change(EmailTemplate, :count).by(8)
      keys = organization.email_templates.pluck(:key)
      expect(keys).to contain_exactly(
        'quote_mailout', 'invoice_mailout', 'receipt_mailout',
        'no_response', 'image_request', 'approval_mailout',
        '48_hour_notice', 'crew_on_the_way'
      )
    end

    it 'stores the approval_mailout subject literally with the placeholder' do
      creator.seed_email_templates
      template = organization.email_templates.find_by(key: 'approval_mailout')
      expect(template.subject).to eq('Your [ORGANIZATION_NAME] Job')
    end

    it 'tags templates with their expected categories' do
      creator.seed_email_templates
      scheduling_keys = organization.email_templates.where(category: 'scheduling').pluck(:key)
      followup_keys = organization.email_templates.where(category: 'followup').pluck(:key)
      default_keys = organization.email_templates.where(category: 'default').pluck(:key)

      expect(scheduling_keys).to contain_exactly('48_hour_notice', 'crew_on_the_way')
      expect(followup_keys).to contain_exactly('no_response', 'image_request')
      expect(default_keys).to contain_exactly(
        'quote_mailout', 'invoice_mailout', 'receipt_mailout', 'approval_mailout'
      )
    end

    it 'is idempotent — running twice results in 8 templates, not 16' do
      creator.seed_email_templates
      expect { creator.seed_email_templates }.not_to change(EmailTemplate, :count)
      expect(organization.email_templates.count).to eq(8)
    end

    it 'does not overwrite existing template content on re-run' do
      organization.email_templates.create!(
        key: 'approval_mailout',
        subject: 'Custom Subject',
        content: 'Custom content'
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
        content: 'Arborist content'
      )
      expect { creator.seed_email_templates }.to change(EmailTemplate, :count).by(7)
      existing.reload
      expect(existing.subject).to eq('Arborist Subject')
      expect(existing.content).to eq('Arborist content')
    end
  end
end
