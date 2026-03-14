# frozen_string_literal: true

# == Schema Information
#
# Table name: taggings
#
#  id          :bigint           not null, primary key
#  estimate_id :bigint
#  tag_id      :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Tagging < ActiveRecord::Base
  belongs_to :estimate
  belongs_to :tag
end
