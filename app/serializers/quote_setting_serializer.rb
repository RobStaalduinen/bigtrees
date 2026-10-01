# frozen_string_literal: true

# == Schema Information
#
# Table name: quote_settings
#
#  id                   :integer          not null, primary key
#  organization_id      :integer          not null
#  include_image_page   :boolean          default(TRUE), not null
#  include_pre_job_page :boolean          default(TRUE), not null
#  include_terms        :boolean          default(TRUE), not null
#
class QuoteSettingSerializer < ApplicationSerializer
  attribute :include_image_page
  attribute :include_pre_job_page
  attribute :include_terms
  attribute :footer_text
  attribute :pre_job_content
  attribute :terms_content
end
