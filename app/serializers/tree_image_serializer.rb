# frozen_string_literal: true

# == Schema Information
#
# Table name: tree_images
#
#  id                 :integer          not null, primary key
#  asset_file_name    :string(255)
#  asset_content_type :string(255)
#  asset_file_size    :integer
#  asset_updated_at   :datetime
#  tree_id            :integer
#  image_url          :string(255)
#  image_small_url    :string(255)
#  edited_image_url   :string(255)
#  estimate_id        :integer
#
class TreeImageSerializer < ApplicationSerializer

  attribute :tree_id
  # Lets the client match a displayed (possibly pending) image back to its
  # in-flight upload job, so it can be killed from the image grid.
  attribute :client_upload_id

  attribute :image_url
  attribute :edited_image_url

  # Virtual
  attribute :url

  # Distinguishes a ready image from a pending (URL-less) placeholder so the
  # frontend never has to guess from a possibly-null image_url.
  attribute :ready do
    object.image_url.present?
  end
  # attribute :image_url_sm
  # attribute :image_url_md

  # attribute :edited_image_url_sm
  # attribute :edited_image_url_md

  belongs_to :tree
end
