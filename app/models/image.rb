# frozen_string_literal: true

# == Schema Information
#
# Table name: images
#
#  id               :integer          not null, primary key
#  imageable_id     :integer
#  imageable_type   :string(255)
#  image_url        :string(255)
#  edited_image_url :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Image < ActiveRecord::Base
  belongs_to :imageable, polymorphic: true
end
