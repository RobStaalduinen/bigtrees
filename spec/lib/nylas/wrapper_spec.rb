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
end
