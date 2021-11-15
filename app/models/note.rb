# frozen_string_literal: true

class Note < ActiveRecord::Base
  include SingleImageable

  belongs_to :estimate
  belongs_to :author, class_name: 'Arborist', foreign_key: :arborist_id

  before_save :set_default_author

  def set_default_author
    self.author ||= estimate.arborist
  end

  def author_name
    self.author&.name
  end
end
