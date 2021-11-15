# frozen_string_literal: true

class Image < ActiveRecord::Base
  belongs_to :imageable, polymorphic: true
end
