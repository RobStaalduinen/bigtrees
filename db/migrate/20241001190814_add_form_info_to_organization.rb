# frozen_string_literal: true

class AddFormInfoToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :short_name, :string
    add_column :organizations, :logo_url, :string
    add_column :organizations, :primary_colour, :string
    add_column :organizations, :secondary_colour, :string
  end
end
