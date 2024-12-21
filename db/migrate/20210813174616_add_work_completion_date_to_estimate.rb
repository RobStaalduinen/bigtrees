class AddWorkCompletionDateToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :estimates, :work_completion_date, :date

    Estimate.joins(:invoice).where("status > 5").each do |e|
      return unless e.invoice.sent_at.present?

      e.update(work_completion_date: e.work_start_date)
    end
  end
end
