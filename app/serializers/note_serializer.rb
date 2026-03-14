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
class NoteSerializer < ApplicationSerializer
  attribute :content
  attribute :author_name
  attribute :created_at

  has_one :image
end
