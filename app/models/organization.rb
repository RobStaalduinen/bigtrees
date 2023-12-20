# frozen_string_literal: true

class Organization < ActiveRecord::Base
  include SingleAddressable

  has_many :organization_memberships
  has_many :arborists, through: :organization_memberships
  has_many :email_templates

  def default_arborist
    arborists.where(role: ['admin', 'super_admin']).first
  end

  def quote_author
    "#{email_author} <#{outgoing_quote_email}>"
  end
end
