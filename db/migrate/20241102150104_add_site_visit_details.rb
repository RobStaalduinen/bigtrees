class AddSiteVisitDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :visit_consent, :boolean, default: false
    add_column :sites, :visit_times, :text
  end
end
