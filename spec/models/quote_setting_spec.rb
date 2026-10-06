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

  describe 'page content' do
    let(:org) { create(:organization, name: 'Big Tree Services') }

    it 'falls back to the stock copy when never customised' do
      expect(org.quote_terms_html).to include('(Completion)')
      expect(org.quote_pre_job_html).to include("We've done this thousands of times")
    end

    it 'expands the organization name macro' do
      expect(org.quote_terms_html).to include('Big Tree Services')
      expect(org.quote_terms_html).not_to include(QuoteContentDefaults::ORGANIZATION_MACRO)
    end

    it 'follows a rename for copy that has not been customised' do
      org.update!(name: 'Renamed Tree Co')

      expect(org.quote_terms_html).to include('Renamed Tree Co')
    end

    it 'uses the stored copy once customised' do
      described_class.create!(organization: org, terms_content: '<p>Our own terms</p>')

      expect(org.reload.quote_terms_html).to eq('<p>Our own terms</p>')
      expect(org.quote_terms_html).not_to include('(Completion)')
    end

    # Clearing the field is how the UI resets to standard, so blank has to mean
    # "track the stock copy" rather than "print nothing".
    it 'returns to the stock copy when cleared' do
      settings = described_class.create!(organization: org, terms_content: '<p>Our own terms</p>')
      settings.update!(terms_content: '')

      expect(org.reload.quote_terms_html).to include('(Completion)')
    end

    it 'keeps the two pages independent' do
      described_class.create!(organization: org, terms_content: '<p>Custom terms</p>')

      expect(org.reload.quote_terms_html).to eq('<p>Custom terms</p>')
      expect(org.quote_pre_job_html).to include("We've done this thousands of times")
    end
  end

  describe 'accent colour' do
    # This value is interpolated into a style attribute on the PDF, so anything
    # that is not plainly a hex colour has to be refused rather than escaped.
    it 'accepts a six digit hex colour' do
      org = create(:organization, primary_colour: '#8A0000')

      expect(org.quote_accent_colour).to eq('#8A0000')
    end

    it 'accepts a three digit hex colour' do
      org = create(:organization, primary_colour: '#abc')

      expect(org.quote_accent_colour).to eq('#abc')
    end

    it 'tolerates surrounding whitespace' do
      org = create(:organization, primary_colour: '  #151F73  ')

      expect(org.quote_accent_colour).to eq('#151F73')
    end

    it 'refuses a named colour, so the stylesheet default is used instead' do
      org = create(:organization, primary_colour: 'red')

      expect(org.quote_accent_colour).to be_nil
    end

    it 'refuses anything carrying extra declarations' do
      org = create(:organization, primary_colour: '#fff; background: url(javascript:alert(1))')

      expect(org.quote_accent_colour).to be_nil
    end

    it 'is nil when unset' do
      expect(create(:organization, primary_colour: nil).quote_accent_colour).to be_nil
      expect(create(:organization, primary_colour: '').quote_accent_colour).to be_nil
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
