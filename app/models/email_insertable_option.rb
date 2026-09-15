# frozen_string_literal: true

# == Schema Information
#
# Table name: email_insertable_options
#
#  id                  :bigint           not null, primary key
#  email_insertable_id :bigint
#  label               :string(255)      not null
#  content             :text(65535)      not null
#  position            :integer          default(0), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class EmailInsertableOption < ActiveRecord::Base
  belongs_to :email_insertable

  validates :label, presence: true
  validates :content, presence: true
end
