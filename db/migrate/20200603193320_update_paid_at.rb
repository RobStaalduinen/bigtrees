class UpdatePaidAt < ActiveRecord::Migration
  def change
    Invoice.where(paid_at: nil).joins(:estimate).where(estimates: { status: 'completed' }).each do |i|
      i.update(paid_at: i.sent_at)
    end
  end
end
