class AddFollowupSentAtToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :estimates, :followup_sent_at, :datetime

    Estimate.where(is_unknown: true).where('estimates.quote_sent_date > ?', Date.today - 1.month).each do |e|
      e.update(followup_sent_at: e.updated_at, is_unknown: false)
    end
  end
end
