require 'rails_helper'

RSpec.describe 'quotes/pdf/_quote.html.erb', type: :view do
  let(:organization) { create(:organization) }
  let(:arborist) { create(:arborist, :admin, organization: organization) }
  let(:customer) { create(:customer) }
  let(:estimate) do
    create(:estimate, :complete, organization: organization, arborist: arborist, customer: customer)
  end

  before do
    stub_template 'quotes/pdf/_header.html.erb' => ''
    stub_template 'quotes/pdf/_footer.html.erb' => ''
    stub_template 'quotes/pdf/_cost_summary.html.erb' => ''
  end

  def render_quote(est, title: 'Quote')
    render partial: 'quotes/pdf/quote',
           locals: { estimate: est.reload, organization: organization, document_title: title }
  end

  describe 'valid until' do
    it 'is omitted when not set' do
      render_quote(estimate)

      expect(rendered).not_to include('Valid until')
    end

    it 'is shown when set' do
      estimate.update!(quote_valid_until: Date.new(2026, 10, 30))

      render_quote(estimate)

      expect(rendered).to include('Valid until')
      expect(rendered).to include('30 October 2026')
    end

    it 'is suppressed once the document is an invoice, where an expiry is meaningless' do
      estimate.update!(quote_valid_until: Date.new(2026, 10, 30))
      create(:invoice, estimate: estimate, number: '2609241')

      render_quote(estimate, title: 'Invoice #2609241')

      expect(rendered).not_to include('Valid until')
    end
  end

  describe 'scope sections' do
    it 'omits all three when no quote_scope exists' do
      render_quote(estimate)

      expect(rendered).not_to include('Scope of work')
      expect(rendered).not_to include("What's included")
      expect(rendered).not_to include('Not included')
    end

    it 'renders only the parts that are filled in' do
      QuoteScope.create!(estimate: estimate, inclusions: ['Stump grinding'])

      render_quote(estimate)

      expect(rendered).to include("What's included")
      expect(rendered).to include('Stump grinding')
      expect(rendered).not_to include('Scope of work')
      expect(rendered).not_to include('Not included')
    end

    # The extra top spacing is only wanted when the scope sections are absent.
    it 'applies the spacious modifier when there is no scope' do
      render_quote(estimate)

      expect(rendered).to include('spacious')
    end

    it 'drops the spacious modifier once any scope section renders' do
      QuoteScope.create!(estimate: estimate, scope_of_work: 'Remove two maples.')

      render_quote(estimate)

      expect(rendered).not_to include('spacious')
    end
  end
end
