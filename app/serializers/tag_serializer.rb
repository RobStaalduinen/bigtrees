# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id              :bigint           not null, primary key
#  organization_id :bigint
#  label           :string(255)      not null
#  colour          :string(255)      not null
#  system          :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class TagSerializer < ApplicationSerializer
  attribute :label
  attribute :colour
  attribute :system
end
