# frozen_string_literal: true

# == Schema Information
#
# Table name: nylas_accounts
#
#  id                     :bigint           not null, primary key
#  organization_id        :bigint           not null
#  outgoing_email_address :string(255)
#  code                   :string(255)
#  grant_id               :string(255)
#  raw_response           :json
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  status                 :string(255)      default("active"), not null
#
class NylasAccount < ActiveRecord::Base
  belongs_to :organization

  enum status: { active: 'active', unsynced: 'unsynced' }

  def validate!
    wrapper = Nylas::Wrapper.new
    wrapper.validate_grant(self)
  end
end
