# frozen_string_literal: true

class Organization < ActiveRecord::Base
  has_many :arborists
end
