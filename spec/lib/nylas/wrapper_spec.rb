# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nylas::Wrapper do
  describe '.missing_send_scope?' do
    def grant(scope)
      { grant_status: 'valid', scope: scope }
    end

    context 'google' do
      it 'accepts gmail.send' do
        expect(described_class.missing_send_scope?(
          grant(['https://www.googleapis.com/auth/gmail.send',
                 'https://www.googleapis.com/auth/userinfo.email'])
        )).to be(false)
      end

      it 'accepts gmail.modify and gmail.compose, which also authorize a send' do
        expect(described_class.missing_send_scope?(grant(['https://www.googleapis.com/auth/gmail.modify']))).to be(false)
        expect(described_class.missing_send_scope?(grant(['https://www.googleapis.com/auth/gmail.compose']))).to be(false)
      end

      it 'accepts the full-access scope' do
        expect(described_class.missing_send_scope?(grant(['https://mail.google.com/']))).to be(false)
      end

      it 'rejects a read-only grant' do
        expect(described_class.missing_send_scope?(grant(['https://www.googleapis.com/auth/gmail.readonly']))).to be(true)
      end
    end

    context 'microsoft' do
      it 'accepts Mail.Send however the provider prefixes it' do
        ['Mail.Send',
         'https://graph.microsoft.com/Mail.Send',
         'https://outlook.office365.com/Mail.Send'].each do |scope|
          expect(described_class.missing_send_scope?(grant([scope, 'User.Read', 'offline_access']))).to be(false)
        end
      end

      it 'rejects Mail.ReadWrite, which does not authorize sendMail' do
        expect(described_class.missing_send_scope?(
          grant(['Mail.ReadWrite', 'User.Read', 'offline_access'])
        )).to be(true)
      end
    end

    it 'handles a space-delimited scope string' do
      expect(described_class.missing_send_scope?(grant('Mail.Send User.Read offline_access'))).to be(false)
    end

    it 'fails open when the grant reports no scopes' do
      expect(described_class.missing_send_scope?(grant([]))).to be(false)
      expect(described_class.missing_send_scope?(grant(nil))).to be(false)
      expect(described_class.missing_send_scope?({ grant_status: 'valid' })).to be(false)
    end
  end

  describe 'application resolution' do
    around do |example|
      original = ENV.to_hash.slice(
        'NYLAS_CLIENT_ID', 'NYLAS_API_KEY', 'NYLAS_SANDBOX_CLIENT_ID',
        'NYLAS_SANDBOX_API_KEY', 'NYLAS_DEFAULT_APPLICATION',
        'TEST_NYLAS_GRANT_ID', 'NYLAS_SANDBOX_TEST_GRANT_ID'
      )

      ENV['NYLAS_CLIENT_ID'] = 'prod-client'
      ENV['NYLAS_API_KEY'] = 'prod-key'
      ENV['NYLAS_SANDBOX_CLIENT_ID'] = 'sandbox-client'
      ENV['NYLAS_SANDBOX_API_KEY'] = 'sandbox-key'
      ENV['TEST_NYLAS_GRANT_ID'] = 'prod-test-grant'
      ENV['NYLAS_SANDBOX_TEST_GRANT_ID'] = 'sandbox-test-grant'
      ENV.delete('NYLAS_DEFAULT_APPLICATION')

      example.run

      %w[NYLAS_CLIENT_ID NYLAS_API_KEY NYLAS_SANDBOX_CLIENT_ID NYLAS_SANDBOX_API_KEY
         NYLAS_DEFAULT_APPLICATION TEST_NYLAS_GRANT_ID NYLAS_SANDBOX_TEST_GRANT_ID].each do |key|
        original.key?(key) ? ENV[key] = original[key] : ENV.delete(key)
      end
    end

    describe '.default_application' do
      it 'is production when unset' do
        expect(described_class.default_application).to eq('production')
      end

      it 'honours the kill switch' do
        ENV['NYLAS_DEFAULT_APPLICATION'] = 'sandbox'
        expect(described_class.default_application).to eq('sandbox')
      end

      it 'ignores an unrecognised value rather than breaking every call' do
        ENV['NYLAS_DEFAULT_APPLICATION'] = 'staging'
        expect(described_class.default_application).to eq('production')
      end
    end

    describe '.credentials_for' do
      it 'reads the flat vars for production and the prefixed vars for sandbox' do
        expect(described_class.credentials_for('production')).to include(
          client_id: 'prod-client', api_key: 'prod-key', test_grant_id: 'prod-test-grant'
        )
        expect(described_class.credentials_for('sandbox')).to include(
          client_id: 'sandbox-client', api_key: 'sandbox-key', test_grant_id: 'sandbox-test-grant'
        )
      end
    end

    describe '.configured?' do
      it 'is false when the application has no credentials' do
        ENV.delete('NYLAS_SANDBOX_API_KEY')
        expect(described_class.configured?('sandbox')).to be(false)
        expect(described_class.configured?('production')).to be(true)
      end
    end

    describe '#initialize' do
      it 'defaults to the default application and exposes it' do
        expect(described_class.new.application).to eq('production')
        expect(described_class.new('sandbox').application).to eq('sandbox')
      end

      it 'rejects an unknown application' do
        expect { described_class.new('staging') }.to raise_error(ArgumentError, /Unknown Nylas application/)
      end

      it 'raises a named error when credentials are missing' do
        ENV.delete('NYLAS_SANDBOX_API_KEY')
        expect { described_class.new('sandbox') }
          .to raise_error(/credentials for the sandbox application are not configured/)
      end
    end

    describe '.for' do
      it 'builds a wrapper bound to the account\'s application' do
        account = build(:nylas_account, :sandbox)
        expect(described_class.for(account).application).to eq('sandbox')
      end
    end
  end

  describe 'state encoding' do
    let(:organization) { build_stubbed(:organization, id: 42) }

    it 'carries the application alongside the organization' do
      expect(described_class.encode_state(organization, 'sandbox')).to eq('42:sandbox')
    end

    it 'round-trips' do
      state = described_class.encode_state(organization, 'sandbox')
      expect(described_class.decode_state(state)).to eq(['42', 'sandbox'])
    end

    it 'accepts a legacy bare organization id, falling back to the default application' do
      expect(described_class.decode_state('42')).to eq(['42', 'production'])
    end

    it 'falls back when the application segment is not recognised' do
      expect(described_class.decode_state('42:staging')).to eq(['42', 'production'])
    end
  end

  describe '.status_for_grant' do
    it 'maps a valid, send-capable grant to active' do
      expect(described_class.status_for_grant({ grant_status: 'valid', scope: ['Mail.Send'] })).to eq('active')
    end

    it 'maps a valid grant without send permission to insufficient' do
      expect(described_class.status_for_grant({ grant_status: 'valid', scope: ['Mail.ReadWrite'] })).to eq('insufficient')
    end

    it 'maps a missing or invalid grant to unsynced' do
      expect(described_class.status_for_grant(nil)).to eq('unsynced')
      expect(described_class.status_for_grant({ grant_status: 'invalid' })).to eq('unsynced')
    end
  end
end
