class PopulateDefaultState < ActiveRecord::Migration[6.0]
  def change
    Estimate.transaction do
      Estimate.skip_callback(:save, :before, :set_status, raise: false)

      Estimate.where(status: 4).each do |e|
        # e.update(state: 'on_hold')
        e.update_column(:state, 'on_hold')
        t = e.organization.tags.find_by(label: 'Pending Permit')
        Tagging.create(tag: t, estimate: e)  
      end

      Estimate.where(is_unknown: true).update_all(state: 'unknown')
      Estimate.completed.update_all(state: 'done')
      Estimate.where(status: 10).update_all(state: 'cancelled')

      Estimate.where(status: [4, 10]).each do |estimate|
        estimate.set_status(false, false)

        estimate.save(validate: false)
      end
    end
  end
end
