# frozen_string_literal: true

class ConfigurationsController < ApplicationController
  def index
    authorize Organization, :update?

    organization_config = Organization.find(params[:organization_id]).configuration

    configurations = YAML.load_file(Rails.root.join('app', 'configuration_templates.yml')).map do |name, config|
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

    organization.configuration[params[:id]] = params[:value]

    organization.save!

    render json: {}, status: :ok
  end
end