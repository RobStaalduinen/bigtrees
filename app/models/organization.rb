# frozen_string_literal: true

class Organization < ActiveRecord::Base
  has_many :arborists

  def default_arborist
    arborists.where(role: ['admin', 'super_admin']).first
  end
end
