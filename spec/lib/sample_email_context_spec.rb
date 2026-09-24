require 'rails_helper'

# The email template preview renders against app/javascript/content/sampleEmailContext.json rather
# than a live record. That only stays honest while the sample looks like what the SPA is actually
# handed, so this walks every path the sample declares and fails if a real payload no longer has it.
#
# The sample is deliberately a subset — it carries what the macros read plus enough surrounding
# context to be recognisable, not every association. Adding a macro means adding whatever it reads
# to the sample; content/emailMacros.test.js fails if a macro has no sample data behind it.
RSpec.describe 'sampleEmailContext.json' do
  SAMPLE_PATH = Rails.root.join('app/javascript/content/sampleEmailContext.json')

  let(:organization) { create(:organization, name: 'Sample Tree Co') }
  let(:arborist) { create(:arborist, :admin, organization: organization) }

  let(:sample) { JSON.parse(File.read(SAMPLE_PATH)) }

  before do
    allow(OrganizationContext).to receive(:current_organization).and_return(organization)
  end

  # Serialized and re-parsed so both sides are plain JSON types — the same thing the browser gets.
  def serialize(record)
    JSON.parse(ActiveModelSerializers::SerializableResource.new(record).to_json).values.first
  end

  def real_estimate_payload
    estimate = create(:estimate, :complete,
                      organization: organization,
                      arborist: arborist,
                      quote_sent_date: Date.new(2026, 4, 2),
                      quote_accepted_date: Date.new(2026, 4, 4),
                      work_start_date: Date.new(2026, 4, 18),
                      work_end_date: Date.new(2026, 4, 19),
                      skip_schedule: false,
                      site_visit: true)

    Job.create!(estimate: estimate,
                arborist: arborist,
                completed_by: arborist,
                started_at: Time.utc(2026, 4, 18, 8),
                completed_at: Time.utc(2026, 4, 19, 15, 30),
                completion_notes: 'Removed the maple.',
                followup_year: 2029)

    Invoice.create!(estimate: estimate, number: '2026-0481', payment_method: 'etransfer',
                    paid: false, sent_at: Date.new(2026, 4, 20))

    serialize(estimate.reload)
  end

  def json_type(value)
    case value
    when nil then :null
    when true, false then :boolean
    when Numeric then :number
    when String then :string
    when Hash then :object
    when Array then :array
    end
  end

  # Presence is always checked; type only where the real payload has a value to compare against.
  def expect_structure(sample_node, real_node, path)
    sample_node.each do |key, sample_value|
      location = path.empty? ? key : "#{path}.#{key}"

      expect(real_node).to have_key(key),
                           "the sample declares #{location}, which a real payload no longer has"

      real_value = real_node[key]
      next if real_value.nil? || sample_value.nil?

      expect(json_type(real_value)).to eq(json_type(sample_value)),
                                       "#{location} is #{json_type(real_value)} on a real payload, " \
                                       "but #{json_type(sample_value)} in the sample"

      case sample_value
      when Hash then expect_structure(sample_value, real_value, location)
      when Array
        first_sample = sample_value.first
        first_real = real_value.first

        if first_sample.is_a?(Hash) && first_real.is_a?(Hash)
          expect_structure(first_sample, first_real, "#{location}[0]")
        end
      end
    end
  end

  it 'is valid JSON with an organization and an estimate' do
    expect(sample).to include('organization', 'estimate')
  end

  it 'matches the structure of a serialized organization' do
    expect_structure(sample['organization'], serialize(organization), 'organization')
  end

  it 'matches the structure of a serialized estimate' do
    expect_structure(sample['estimate'], real_estimate_payload, 'estimate')
  end

  it 'carries a job, which is where the notes and follow-up macros read from' do
    job = sample.dig('estimate', 'jobs', 0)

    expect(job['completion_notes']).to be_present
    expect(job['followup_year']).to be_present
  end

  it 'fills in the fields the macros read' do
    estimate = sample['estimate']

    expect(estimate.dig('customer_detail', 'name')).to be_present
    expect(estimate['total_cost']).to be_present
    expect(estimate['total_cost_with_tax']).to be_present
    expect(sample.dig('organization', 'name')).to be_present
    expect(sample.dig('organization', 'email_signature')).to be_present
  end
end
