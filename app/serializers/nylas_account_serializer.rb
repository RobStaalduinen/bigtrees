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
# frozen_stirng_literal: true

class NylasAccountSerializer < ApplicationSerializer
  attribute :outgoing_email_address
  attribute :status
end
