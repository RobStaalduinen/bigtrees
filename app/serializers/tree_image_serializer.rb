# frozen_string_literal: true

class TreeImageSerializer < ApplicationSerializer

  attribute :edited_image_url

  # Virtual
  attribute :url
  attribute :image_url_sm
  attribute :image_url_md

  attribute :edited_image_url_sm
  attribute :edited_image_url_md
end
