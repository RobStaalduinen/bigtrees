require 'rubyXL'

class GenerateQuote

  def self.call(estimate)
    template = Rails.root.join("lib", "quote_template.xlsx")
    destination = Rails.root.join("tmp", "Quote-Estimate_#{estimate.id}.xlsx")

    FileUtils.cp(template, destination)

    workbook = RubyXL::Parser.parse(template)
    worksheet = workbook[0]

    # binding.pry

    if estimate.invoice_number.present?
      # Invoice Number
      worksheet[3][4].change_contents("Invoice ##{estimate.invoice_number}")
    end

    # Date
    worksheet[4][2].change_contents(Date.today.strftime("%d/%m/%Y"))
    # Customer Name
    worksheet[5][2].change_contents(estimate.person_name)
    # Phone Number
    worksheet[6][2].change_contents(estimate.phone)
    # Email Address
    worksheet[7][2].change_contents(estimate.email)
    # Address
    worksheet[8][2].change_contents(estimate.full_address)

    arborist = estimate.arborist

    if estimate.work_date.present?
      # Completion Date
      worksheet[4][7].change_contents(estimate.work_date.strftime("%d/%m/%Y"))
    end
    # Arborist Name
    worksheet[5][7].change_contents(arborist.name)
    # Arborist Cert
    worksheet[6][7].change_contents(arborist.certification)
    # Arborist Phone
    worksheet[7][7].change_contents(arborist.phone_number)
    # Arborist Email
    worksheet[8][7].change_contents(arborist.email)

    estimate.trees.each_with_index do |tree, i|
      worksheet[10 + i][0].change_contents(tree.notes)
      worksheet[10 + i][7].change_contents(tree.cost.to_f)
    end

    tree_count = estimate.trees.count

    worksheet[10 + tree_count][0].change_contents(estimate.extra_cost_notes)
    worksheet[10 + tree_count][7].change_contents(estimate.extra_cost.to_f)

    subtotal = estimate.trees.sum(:cost) + estimate.extra_cost

    if estimate.discount_applied
      worksheet[10 + tree_count + 1][0].change_contents(Estimate::SIGN_DISCOUNT_MESSAGE)
      worksheet[10 + tree_count + 1][7].change_contents(Estimate::SIGN_DISCOUNT)
      subtotal += Estimate::SIGN_DISCOUNT
    end

    

    hst = (subtotal * 0.13).round(2)
    worksheet[19][7].change_contents("$#{sprintf("%.2f", subtotal.to_f)}")
    worksheet[20][7].change_contents("$#{sprintf("%.2f", hst.to_f)}")
    worksheet[22][7].change_contents("$#{sprintf("%.2f", (subtotal + hst))}")

    workbook.write(destination)
    
    return destination
  end
end
