# frozen_string_literal: true

class DocumentSerializer < ApplicationSerializer
  attribute :name
  attribute :file_url
  attribute :expires_at
end
