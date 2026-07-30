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

  before_validation :set_default_author
  before_validation :snapshot_author_name

  def set_default_author
    self.author ||= estimate&.arborist
  end

  # Record the author's name on the note when it is first written so the
  # displayed author stays fixed to who wrote it, even if the arborist is
  # later renamed or the note is transferred to another organization. Only set
  # when blank so it is never rewritten after creation.
  def snapshot_author_name
    self.author_name ||= author&.name
  end
end
