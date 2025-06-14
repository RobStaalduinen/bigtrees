class AddCompletionSurveyQuestionsToOrganization < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :completion_survey_questions, :json

    Organization.find_each do |organization|
      organization.update(completion_survey_questions: ['Is the customer happy with the work?'])
    end

    add_column :jobs, :completion_survey_responses, :json
    add_column :jobs, :completion_notes, :text
    add_column :jobs, :followup_year, :integer
  end
end
