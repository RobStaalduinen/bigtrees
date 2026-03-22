class AddSourceToEstimates < ActiveRecord::Migration[6.0]
  def change
    add_column :estimates, :source, :string
  end
end
