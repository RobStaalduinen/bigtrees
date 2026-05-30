class AddDifficultyToEstimates < ActiveRecord::Migration[6.0]
  def change
    add_column :estimates, :difficulty, :string, default: 'medium', null: false
  end
end
