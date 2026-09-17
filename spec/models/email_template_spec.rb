require 'rails_helper'

RSpec.describe EmailTemplate do
  let(:organization) { create(:organization) }

  def build_template(attributes)
    organization.email_templates.build({ subject: 'Subject', content: 'Body' }.merge(attributes))
  end

  describe 'categories' do
    it 'accepts every workflow category' do
      EmailTemplate::CATEGORIES.each_with_index do |category, index|
        template = build_template(key: "template_#{index}", category: category)

        expect(template).to be_valid, "expected #{category} to be a valid category"
      end
    end

    it 'no longer accepts the retired default category' do
      template = build_template(key: 'anything', category: 'default')

      expect(template).not_to be_valid
      expect(template.errors[:category]).to be_present
    end

    it 'requires a category' do
      template = build_template(key: 'anything', category: nil)

      expect(template).not_to be_valid
      expect(template.errors[:category]).to be_present
    end
  end

  describe '#deletable?' do
    it 'protects every template the workflow sends by key' do
      EmailTemplate::SYSTEM_KEYS.each do |key|
        template = build_template(key: key, category: 'quote')

        expect(template).to be_system, "expected #{key} to be a system template"
        expect(template).not_to be_deletable
      end
    end

    it 'leaves a template the organization added deletable' do
      template = build_template(key: 'spring_promo', category: 'quote')

      expect(template).not_to be_system
      expect(template).to be_deletable
    end
  end
end
