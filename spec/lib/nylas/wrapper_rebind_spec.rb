# frozen_string_literal: true

require 'rails_helper'

# The self-heal path: an account bound to the wrong Nylas application sees a 404
# from its own application, because a grant is only visible to the application
# that created it.
RSpec.describe Nylas::Wrapper, 'application rebinding' do
  around do |example|
    keys = %w[NYLAS_CLIENT_ID NYLAS_API_KEY NYLAS_SANDBOX_CLIENT_ID NYLAS_SANDBOX_API_KEY
              NYLAS_DEFAULT_APPLICATION]
    original = ENV.to_hash.slice(*keys)

    ENV['NYLAS_CLIENT_ID'] = 'prod-client'
    ENV['NYLAS_API_KEY'] = 'prod-key'
    ENV['NYLAS_SANDBOX_CLIENT_ID'] = 'sandbox-client'
    ENV['NYLAS_SANDBOX_API_KEY'] = 'sandbox-key'
    ENV.delete('NYLAS_DEFAULT_APPLICATION')

    example.run

    keys.each { |key| original.key?(key) ? ENV[key] = original[key] : ENV.delete(key) }
  end

  let(:account) { create(:nylas_account, grant_id: 'grant-abc') }

  def not_found
    Nylas::NylasApiError.new('NylasApiError', 'grant not found', 404)
  end

  def valid_grant
    { grant_status: 'valid', scope: ['https://www.googleapis.com/auth/gmail.send'] }
  end

  # Stubs the grants endpoint per application, keyed by the api_key the wrapper
  # was constructed with.
  def stub_grants(production:, sandbox:)
    allow(Nylas::Client).to receive(:new) do |api_key:, **|
      behaviour = api_key == 'sandbox-key' ? sandbox : production
      grants = double('grants')

      allow(grants).to receive(:find) do
        behaviour.is_a?(Exception) ? raise(behaviour) : [behaviour, 'req-id']
      end

      double('client', grants: grants)
    end
  end

  it 'rebinds to the other application when that application owns the grant' do
    stub_grants(production: not_found, sandbox: valid_grant)

    expect(described_class.new('production').refresh_status(account)).to eq('active')

    expect(account.reload.nylas_application).to eq('sandbox')
    expect(account.status).to eq('active')
  end

  it 'carries the recovered status through, not just the binding' do
    stub_grants(production: not_found, sandbox: { grant_status: 'valid', scope: ['Mail.ReadWrite'] })

    expect(described_class.new('production').refresh_status(account)).to eq('insufficient')
    expect(account.reload.nylas_application).to eq('sandbox')
  end

  it 'leaves the binding alone and reports unsynced when neither application has the grant' do
    stub_grants(production: not_found, sandbox: not_found)

    expect(described_class.new('production').refresh_status(account)).to eq('unsynced')

    expect(account.reload.nylas_application).to eq('production')
    expect(account.status).to eq('unsynced')
  end

  it 'does not rebind a grant that is merely revoked' do
    stub_grants(production: { grant_status: 'invalid' }, sandbox: valid_grant)

    expect(described_class.new('production').refresh_status(account)).to eq('unsynced')
    expect(account.reload.nylas_application).to eq('production')
  end

  it 'does not rebind on a non-404 error' do
    stub_grants(production: Nylas::NylasApiError.new('NylasApiError', 'boom', 500), sandbox: valid_grant)

    expect(described_class.new('production').refresh_status(account)).to eq('unsynced')
    expect(account.reload.nylas_application).to eq('production')
  end

  it 'skips the rebind entirely once the other application has no credentials' do
    ENV.delete('NYLAS_SANDBOX_API_KEY')
    stub_grants(production: not_found, sandbox: valid_grant)

    expect(described_class.new('production').refresh_status(account)).to eq('unsynced')
    expect(account.reload.nylas_application).to eq('production')
  end
end
