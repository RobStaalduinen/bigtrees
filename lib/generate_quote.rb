require 'rubyXL'

class GenerateQuote

  def self.call(estimate)
    template = Rails.root.join("lib", "quote_template.xlsx")
    destination = Rails.root.join("tmp", "Quote-Estimate_#{estimate.id}.xlsx")

    FileUtils.cp(template, destination)

    workbook = RubyXL::Parser.parse(template)
    worksheet = workbook[0]

    # binding.pry

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
    hst = (subtotal * 0.13).round(2)
    worksheet[19][7].change_contents("$#{sprintf("%.2f", subtotal.to_f)}")
    worksheet[20][7].change_contents("$#{sprintf("%.2f", hst.to_f)}")
    worksheet[22][7].change_contents("$#{sprintf("%.2f", (subtotal + hst))}")

    workbook.write(destination)
    
    return destination
  end
end
