# frozen_string_literal: true

class OrganizationSerializer < ApplicationSerializer
  attribute :name

  attribute :phone_number
  attribute :website
  attribute :email

  attribute :email_author
  attribute :email_signature
  attribute :outgoing_quote_email
  attribute :quote_bcc

  attribute :insurance_provider
  attribute :insurance_policy_number
  attribute :insurance_description

  belongs_to :address
end
