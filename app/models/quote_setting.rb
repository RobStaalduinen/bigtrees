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
# Which optional pages an organization's quote PDF carries. Absence of a record
# means "all pages", which is what every quote did before this existed — see
# Organization#include_quote_* for the readers that encode that.
class QuoteSetting < ActiveRecord::Base
  belongs_to :organization

  PAGE_FLAGS = %i[include_image_page include_pre_job_page include_terms].freeze
end
