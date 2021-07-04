class AddSurveyFilledOutToSite < ActiveRecord::Migration
  def change
    add_column :sites, :survey_filled_out, :boolean, default: false

    Site.update_all(survey_filled_out: true)
  end
end
