class AddExistingJobs < ActiveRecord::Migration[6.0]
  def change
    Estimate.where(status: ['completed', 'final_invoice_sent']).find_each do |estimate|
      next if estimate.job.present?

      Job.create(estimate: estimate, skipped: true)
    end
  end
end
