require 'rails_helper'

RSpec.describe 'quotes/pdf/_images.html.erb', type: :view do
  let(:organization) { create(:organization) }
  let(:arborist) { create(:arborist, :admin, organization: organization) }
  let(:customer) { create(:customer) }
  let(:estimate) { create(:estimate, :complete, organization: organization, arborist: arborist, customer: customer) }

  before do
    # The partial renders the shared header sub-partial; stub it so this spec
    # focuses on the pending-image filtering.
    stub_template 'quotes/pdf/_header.html.erb' => ''
  end

  it 'renders ready images and omits pending (URL-less) images without raising' do
    TreeImage.create!(estimate: estimate, image_url: 'https://example.com/ready.jpg')
    TreeImage.create!(estimate: estimate, image_url: nil)

    expect {
      render partial: 'quotes/pdf/images', locals: { estimate: estimate.reload, organization: organization }
    }.not_to raise_error

    expect(rendered).to include('https://example.com/ready.jpg')
  end

  it 'renders nothing (no page) when every image is pending' do
    TreeImage.create!(estimate: estimate, image_url: nil)

    render partial: 'quotes/pdf/images', locals: { estimate: estimate.reload, organization: organization }

    expect(rendered).not_to include('Proposed Work')
  end
end
