class AddWorkDateToEstimate < ActiveRecord::Migration
  def change
    add_column :estimates, :quote_sent_date, :date
    add_column :estimates, :quote_accepted_date, :date
    add_column :estimates, :work_date, :date
  end
end
