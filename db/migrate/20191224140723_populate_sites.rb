class PopulateSites < ActiveRecord::Migration[5.2]
  def change
    Estimate.all.each do |estimate|
      Site.create(
        estimate: estimate,
        street: estimate.street,
        city: estimate.city,
        vehicle_access: estimate.vehicle_access,
        breakables: estimate.breakables,
        wood_removal: estimate.wood_removal,
        access_width: estimate.access_width
      )
    end
  end
end
