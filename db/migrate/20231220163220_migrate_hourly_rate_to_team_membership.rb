class MigrateHourlyRateToTeamMembership < ActiveRecord::Migration[5.2]
  def self.up
    add_column :organization_memberships, :hourly_rate, :float, default: 0

    Arborist.all.each do |a|
      a.organization_memberships.update_all(hourly_rate: a.hourly_rate)
    end
  end

  def self.down
    remove_column :organization_memberships, :hourly_rate
  end
end
