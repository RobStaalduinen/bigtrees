require 'rails_helper'

RSpec.describe QuoteSetting, type: :model do
  let(:organization) { create(:organization) }

  describe 'defaults' do
    it 'includes every page when nothing is specified' do
      settings = described_class.create!(organization: organization)

      expect(settings.include_image_page).to be(true)
      expect(settings.include_pre_job_page).to be(true)
      expect(settings.include_terms).to be(true)
    end
  end

  describe 'Organization readers' do
    # Absence of a record has to mean "include everything" — that is how quotes
    # behaved before this table existed, and every organization starts without
    # a record.
    it 'treats a missing record as all pages included' do
      expect(organization.quote_settings).to be_nil

      expect(organization.include_quote_image_page?).to be(true)
      expect(organization.include_quote_pre_job_page?).to be(true)
      expect(organization.include_quote_terms?).to be(true)
    end

    it 'reflects the stored flags once a record exists' do
      described_class.create!(
        organization: organization,
        include_image_page: false,
        include_pre_job_page: false,
        include_terms: true
      )
      organization.reload

      expect(organization.include_quote_image_page?).to be(false)
      expect(organization.include_quote_pre_job_page?).to be(false)
      expect(organization.include_quote_terms?).to be(true)
    end
  end

  describe 'footer text' do
    let(:insured) do
      create(:organization,
             insurance_provider: 'Intact Insurance',
             insurance_policy_number: '501381704',
             insurance_description: '$2,000,000 Commercial General Liability',
             hst_number: '752547802RT0001')
    end

    it 'builds the default from the organization insurance and tax fields' do
      expect(insured.default_quote_footer_text)
        .to eq('Insured with Intact Insurance, policy 501381704, $2,000,000 Commercial General Liability   HST 752547802RT0001')
    end

    it 'omits the parts an organization has not filled in' do
      partial = create(:organization,
                       insurance_provider: 'Intact Insurance',
                       insurance_policy_number: nil,
                       insurance_description: nil,
                       hst_number: nil)

      expect(partial.default_quote_footer_text).to eq('Insured with Intact Insurance')
    end

    it 'is empty for an organization with neither insurance nor tax details' do
      bare = create(:organization,
                    insurance_provider: nil, insurance_policy_number: nil,
                    insurance_description: nil, hst_number: nil)

      expect(bare.default_quote_footer_text).to eq('')
    end

    it 'falls back to the default when no record exists' do
      expect(insured.quote_footer_text).to eq(insured.default_quote_footer_text)
    end

    it 'falls back to the default when the stored text is blank' do
      described_class.create!(organization: insured, footer_text: '')

      expect(insured.reload.quote_footer_text).to eq(insured.default_quote_footer_text)
    end

    it 'uses the stored text once set' do
      described_class.create!(organization: insured, footer_text: "Line one\nLine two")

      expect(insured.reload.quote_footer_text).to eq("Line one\nLine two")
    end
  end

  describe 'association' do
    it 'is limited to one per organization' do
      described_class.create!(organization: organization)

      expect { described_class.create!(organization: organization) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'is destroyed with the organization' do
      described_class.create!(organization: organization)

      expect { organization.destroy }.to change(described_class, :count).by(-1)
    end
  end
end
