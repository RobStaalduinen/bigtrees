# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NylasAccount do
  describe 'grant_id presence' do
    it 'refuses to persist an account with no grant' do
      account = build(:nylas_account, grant_id: nil)

      expect(account).not_to be_valid
      expect(account.errors[:grant_id]).to be_present
    end
  end

  describe '#refresh_status!' do
    it 'delegates to the wrapper' do
      account = create(:nylas_account)
      wrapper = instance_double(Nylas::Wrapper)

      expect(Nylas::Wrapper).to receive(:new).and_return(wrapper)
      expect(wrapper).to receive(:refresh_status).with(account).and_return('active')

      expect(account.refresh_status!).to eq('active')
    end
  end
end
