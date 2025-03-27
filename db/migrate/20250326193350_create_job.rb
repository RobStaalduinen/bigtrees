class CreateJob < ActiveRecord::Migration[6.0]
  def change
    create_table :jobs do |t|
      t.belongs_to :estimate, null: false
    
      t.datetime :started_at
      t.datetime :completed_at

      t.json :job_survey_responses

      t.timestamps
    end
  end
end
