# frozen_string_literal: true

# == Schema Information
#
# Table name: email_insertables
#
#  id              :bigint           not null, primary key
#  organization_id :bigint
#  key             :string(255)      not null
#  label           :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class EmailInsertableSerializer < ApplicationSerializer
  attribute :key
  attribute :label

  has_many :options, serializer: EmailInsertableOptionSerializer
end
