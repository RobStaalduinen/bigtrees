# frozen_string_literal: true

class EmailTemplateSerializer < ApplicationSerializer
  attribute :key
  attribute :subject
  attribute :parsed_subject
  attribute :content
  attribute :created_at
end
