class AddStumpingOnlyToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :estimates, :stumping_only, :boolean, default: false
    add_column :estimates, :access_width, :string

    add_column :trees, :in_backyard, :boolean, default: false
  end
end
