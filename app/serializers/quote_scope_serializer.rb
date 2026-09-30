# frozen_string_literal: true

# == Schema Information
#
# Table name: quote_scopes
#
#  id            :integer          not null, primary key
#  estimate_id   :integer          not null
#  scope_of_work :text
#  inclusions    :json
#  exclusions    :json
#
class QuoteScopeSerializer < ApplicationSerializer
  attribute :scope_of_work
  attribute :inclusions
  attribute :exclusions
end
