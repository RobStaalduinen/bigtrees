# frozen_string_literal: true

class NoteSerializer < ApplicationSerializer
  attribute :content
  attribute :author_name
  attribute :created_at

  has_one :image
end
