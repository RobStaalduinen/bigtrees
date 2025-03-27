class AddJobSurveyQuestionsToOrganization < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :job_survey_questions, :json
  end
end
