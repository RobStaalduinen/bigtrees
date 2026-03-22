require 'rails_helper'

RSpec.describe Organizations::Create do
  let(:params) do
    {
      name: 'Acme Tree Service',
      legal_name: 'Acme Tree Service Inc.',
      contact_person: 'Jane Smith',
      email: 'jane@acme.com',
      website: 'https://acme.com',
      primary_colour: '#336699',
      secondary_colour: '#993366'
    }
  end

  subject(:result) { described_class.call(params) }

  it 'creates an organization' do
    expect { result }.to change(Organization, :count).by(1)
  end

  it 'creates a blank address for the organization' do
    expect { result }.to change(Address, :count).by(1)
    expect(result[:organization].address).to be_present
  end

  it 'returns the organization' do
    expect(result[:organization]).to be_a(Organization)
    expect(result[:organization].name).to eq('Acme Tree Service')
  end

  it 'returns a temporary password' do
    expect(result[:temporary_password]).to be_present
  end

  describe 'organization attributes' do
    subject(:org) { result[:organization] }

    it 'sets legal_name' do
      expect(org.legal_name).to eq('Acme Tree Service Inc.')
    end

    it 'sets email' do
      expect(org.email).to eq('jane@acme.com')
    end

    it 'sets website' do
      expect(org.website).to eq('https://acme.com')
    end

    it 'sets primary_colour' do
      expect(org.primary_colour).to eq('#336699')
    end

    it 'sets secondary_colour' do
      expect(org.secondary_colour).to eq('#993366')
    end

    it 'sets configuration to an empty hash' do
      expect(org.configuration).to eq({})
    end

    it 'populates job_survey_questions' do
      expect(org.job_survey_questions).to eq(Organizations::Create::JOB_SURVEY_QUESTIONS)
    end

    it 'populates completion_survey_questions' do
      expect(org.completion_survey_questions).to eq(Organizations::Create::COMPLETION_SURVEY_QUESTIONS)
    end
  end

  describe 'default tags' do
    it 'creates two default tags' do
      expect { result }.to change(Tag, :count).by(2)
    end

    it 'creates the expected tag labels' do
      tags = result[:organization].tags
      expect(tags.map(&:label)).to contain_exactly('Site Visit', 'Pending Permit')
    end

    it 'marks tags as system tags' do
      expect(result[:organization].tags.all?(&:system)).to be true
    end
  end

  describe 'admin arborist' do
    it 'creates an arborist' do
      expect { result }.to change(Arborist, :count).by(1)
    end

    it 'creates an organization membership' do
      expect { result }.to change(OrganizationMembership, :count).by(1)
    end

    it 'sets name from contact_person' do
      expect(result[:organization].arborists.first.name).to eq('Jane Smith')
    end

    it 'sets email' do
      expect(result[:organization].arborists.first.email).to eq('jane@acme.com')
    end

    it 'sets role to admin' do
      expect(result[:organization].arborists.first.role).to eq('admin')
    end

    it 'authenticates with the returned temporary password' do
      arborist = result[:organization].arborists.first
      expect(arborist.authenticate(result[:temporary_password])).to be_truthy
    end
  end

  describe 'transaction safety' do
    before do
      allow(Tag).to receive(:create_default).and_raise(ActiveRecord::RecordInvalid)
    end

    it 'does not create an organization on failure' do
      expect { result rescue nil }.not_to change(Organization, :count)
    end

    it 'does not create an arborist on failure' do
      expect { result rescue nil }.not_to change(Arborist, :count)
    end
  end
end
