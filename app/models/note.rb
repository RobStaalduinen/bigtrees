# frozen_string_literal: true

# == Schema Information
#
# Table name: notes
#
#  id          :integer          not null, primary key
#  estimate_id :integer
#  arborist_id :integer
#  content     :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
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
