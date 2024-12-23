class AddSurveyFilledOutToSite < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :survey_filled_out, :boolean, default: false

    Site.update_all(survey_filled_out: true)
  end
end
