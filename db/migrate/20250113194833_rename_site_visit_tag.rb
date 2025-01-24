# frozen_string_literal: true

class RenameSiteVisitTag < ActiveRecord::Migration[6.0]
  def change
    rename_column :estimates, :site_visit_tag, :site_visit
  end
end
