# frozen_string_literal: true

class AddSiteVisitTagToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :estimates, :site_visit_tag, :boolean, default: false
  end
end
