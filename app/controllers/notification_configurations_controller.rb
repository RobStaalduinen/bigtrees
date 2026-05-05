# frozen_string_literal: true

class NotificationConfigurationsController < ApplicationController
  def index
    authorize Organization, :update?

    org = Organization.find(params[:organization_id])
    raw_config = org.notification_configuration
    organization_config = raw_config.is_a?(String) ? JSON.parse(raw_config) : (raw_config || {})

    configurations = YAML.load_file(Rails.root.join('app', 'notification_templates.yml')).map do |name, config|
      {
        name: name,
        description: config['description'],
        value: organization_config[name].nil? ? config['default'] : organization_config[name]
      }
    end

    render json: configurations
  end

  def update
    authorize Organization, :update?

    organization = Organization.find(params[:organization_id])

    current_config = organization.notification_configuration
    current_config = current_config.is_a?(String) ? JSON.parse(current_config) : (current_config || {})
    organization.notification_configuration = current_config.merge(params[:id] => params[:value])

    organization.save!

    render json: {}, status: :ok
  end
end
