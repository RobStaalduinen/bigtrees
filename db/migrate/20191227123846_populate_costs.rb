class PopulateCosts < ActiveRecord::Migration[5.2]
  def change
    Estimate.all.each do |estimate|
      next unless estimate.trees.any?

      estimate.trees.each do |tree|
        Cost.create(
          estimate: estimate,
          amount: tree.cost,
          description: tree.notes
        )
      end

      if estimate.extra_costs.any?
        estimate.extra_costs.each do |ex|
          Cost.create(
            estimate: estimate,
            amount: ex.amount,
            description: ex.description
          )
        end
      end

      if estimate.invoice.discount?
        Cost.create(
          estimate: estimate,
          amount: -25.0,
          description: "Discount for Sign Placement",
          discount: true
        )
      end
      
    end
  end
end
