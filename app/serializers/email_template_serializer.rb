# frozen_string_literal: true

# == Schema Information
#
# Table name: email_templates
#
#  id              :bigint           not null, primary key
#  organization_id :bigint
#  key             :string(255)
#  subject         :string(255)
#  content         :text(65535)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class EmailTemplateSerializer < ApplicationSerializer
  attribute :key
  attribute :subject
  attribute :parsed_subject
  attribute :content
  attribute :created_at
end
