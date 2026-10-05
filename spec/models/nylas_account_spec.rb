# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NylasAccount do
  describe 'nylas_application' do
    it 'defaults to production for new records' do
      expect(create(:nylas_account).nylas_application).to eq('production')
    end

    it 'exposes prefixed predicates that do not collide with status' do
      account = create(:nylas_account, :sandbox)

      expect(account.nylas_application_sandbox?).to be(true)
      expect(account.nylas_application_production?).to be(false)
      expect(account.active?).to be(true)
    end
  end

  describe 'grant_id presence' do
    it 'refuses to persist an account with no grant' do
      account = build(:nylas_account, grant_id: nil)

      expect(account).not_to be_valid
      expect(account.errors[:grant_id]).to be_present
    end
  end

  describe '#refresh_status!' do
    it 'delegates to a wrapper bound to the account application' do
      account = create(:nylas_account, :sandbox)
      wrapper = instance_double(Nylas::Wrapper)

      expect(Nylas::Wrapper).to receive(:for).with(account).and_return(wrapper)
      expect(wrapper).to receive(:refresh_status).with(account).and_return('active')

      expect(account.refresh_status!).to eq('active')
    end
  end
end
