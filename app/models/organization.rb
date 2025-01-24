# frozen_string_literal: true

class Organization < ActiveRecord::Base
  include SingleAddressable

  has_many :organization_memberships, dependent: :destroy
  has_many :arborists, through: :organization_memberships
  has_many :email_templates
  has_many :estimates
  has_many :quick_costs
  has_many :tags

  def default_arborist
    arborists.where(role: ['admin', 'super_admin']).first
  end

  def quote_author
    "#{email_author} <#{outgoing_quote_email}>"
  end
end
