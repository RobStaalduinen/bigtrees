class PopulateExtraCosts < ActiveRecord::Migration
  def change
    Estimate.where.not(extra_cost: nil).each do |e|
      ExtraCost.create(
        estimate: e,
        amount: e.extra_cost,
        description: e.extra_cost_notes
      )
    end
  end
end
