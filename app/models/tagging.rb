# frozen_string_literal: true

class Tagging < ActiveRecord::Base
  belongs_to :estimate
  belongs_to :tag
end