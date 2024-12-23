# frozen_string_literal: true

class CreateQuickCosts < ActiveRecord::Migration[5.2]
  def change
    create_table :quick_costs do |t|
      t.belongs_to :organization
      t.string :label
      t.string :content
      t.decimal :default_cost, precision: 8, scale: 2, default: 0.0

      t.timestamps null: false
    end

    Organization.all.each do |organization|
      create_default_quick_costs(organization)
    end
  end

  def create_default_quick_costs(organization)
      quick_costs = [
        { label: 'Removal', content: 'Tree Cut Down' },
        { label: 'Stump', content: 'Grind stump (6" depth) and any visible surface roots' },
        { label: 'Cleanup', content: 'Site Cleanup - Branches Disposed, Rake Lawn, Street/Driveway Swept' },
        { label: 'Logs', content: 'Disposal of Log/Trunk Wood over 6" diameter' },
        { label: 'Grindings', content: 'Stump Grindings and Root Debris Disposal' },
        { label: 'Trim', content: 'Tree Trim' },
        { label: 'Report', content: 'Arborist Report (City Fees and Replanting Costs extra if necessary)' },
        { label: 'Gutter', content: 'Dispose of all Gutter Debris and test for proper flow' },
        { label: 'Inject', content: 'Deep Root Fertilizer Injections' },
        { label: 'Spray', content: 'Spruce Tree Fungicide Spray for Rhizosphaera Needlecast Prevention' },
        { label: 'Garden', content: 'General tidy and cleanup of the garden beds (pruning, weeding and mulch incl.)' }
      ]

      quick_costs.each do |cost|
        organization.quick_costs.create(label: cost[:label], content: cost[:content], default_cost: 0.0)
      end
  end
end
