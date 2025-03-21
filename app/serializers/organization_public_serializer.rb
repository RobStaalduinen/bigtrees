# frozen_string_literal: true

class OrganizationPublicSerializer < ApplicationSerializer
  attribute :name

  attribute :phone_number
  attribute :website
  attribute :email

  attribute :logo_url
  attribute :primary_colour
  attribute :secondary_colour

  attribute :quote_redirect_link
end
