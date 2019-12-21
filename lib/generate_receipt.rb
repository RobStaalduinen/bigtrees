require 'rubyXL'

class GenerateReceipt

  def self.call(estimate)
    template = Rails.root.join("lib", "payment_receipt_template.xlsx")
    destination = Rails.root.join("tmp", "Receipt-Estimate_#{estimate.id}.xlsx")

    FileUtils.cp(template, destination)

    workbook = RubyXL::Parser.parse(template)
    worksheet = workbook[0]

    invoice = estimate.invoice

    # Date
    worksheet[4][2].change_contents(invoice.paid_at.strftime("%d/%m/%Y"))
    # Customer Name
    worksheet[5][2].change_contents(estimate.customer.name)
    # Invoice Number
    worksheet[6][2].change_contents("##{estimate.invoice.number}")

    estimate.trees.each_with_index do |tree, i|
      worksheet[9 + i][0].change_contents(tree.notes)
      worksheet[9 + i][7].change_contents(tree.cost.to_f)
    end

    tree_count = estimate.trees.count
    extra_cost_count = estimate.extra_costs.count

    estimate.extra_costs.each_with_index do |cost, i|
      worksheet[9 + tree_count + i][0].change_contents(cost.description)
      worksheet[9 + tree_count + i][7].change_contents(cost.amount.to_f)
    end

    subtotal = estimate.total_cost

    if estimate.invoice && estimate.invoice.discount
      worksheet[10 + tree_count + extra_cost_count][0].change_contents(Estimate::SIGN_DISCOUNT_MESSAGE)
      worksheet[10 + tree_count + extra_cost_count][7].change_contents(Estimate::SIGN_DISCOUNT)
      
    end

    hst = (subtotal * 0.13).round(2)
    worksheet[18][7].change_contents("$#{sprintf("%.2f", subtotal.to_f)}")
    worksheet[19][7].change_contents("$#{sprintf("%.2f", hst.to_f)}")
    worksheet[21][7].change_contents("$#{sprintf("%.2f", (subtotal + hst))}")

    worksheet[23][7].change_contents(invoice.payment_method)

    workbook.write(destination)
    
    return destination
  end
end
