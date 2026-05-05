class AddNotificationConfigurationToOrganizations < ActiveRecord::Migration[6.0]
  def up
    add_column :organizations, :notification_configuration, :json

    Organization.find_each do |org|
      next if org.configuration.blank?

      job_notifications = org.configuration['job_notifications']
      next if job_notifications.nil?

      org.update_columns(
        notification_configuration: { 'job' => job_notifications },
        configuration: org.configuration.except('job_notifications')
      )
    end
  end

  def down
    Organization.find_each do |org|
      next if org.notification_configuration.blank?

      job = org.notification_configuration['job']
      next if job.nil?

      org.update_columns(
        configuration: (org.configuration || {}).merge('job_notifications' => job),
        notification_configuration: org.notification_configuration.except('job')
      )
    end

    remove_column :organizations, :notification_configuration
  end
end
