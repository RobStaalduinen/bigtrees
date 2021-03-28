# frozen_string_literal: true

class DocumentSerializer < ApplicationSerializer
  attribute :arborist_id
  attribute :name
  attribute :file_url
  attribute :expires_at
end
