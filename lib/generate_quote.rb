require 'rubyXL'
require 'rubyXL/convenience_methods'

class GenerateQuote

  def self.call(estimate)
    template_file = estimate.final? ? "final_template.xlsx" : "quote_template.xlsx"
    template = Rails.root.join("lib", template_file)

    destination = Rails.root.join("tmp", "Quote-Estimate_#{estimate.id}.xlsx")

    FileUtils.cp(template, destination)

    workbook = RubyXL::Parser.parse(template)
    worksheet = workbook[0]

    if estimate.final?
      # Invoice Number
      worksheet[3][4].change_contents("Invoice ##{estimate.invoice.number}")
    end

    # Date
    worksheet[4][2].change_contents(Date.today.strftime("%d/%m/%Y"))
    # Customer Name
    worksheet[5][2].change_contents(estimate.customer.name)
    # Phone Number
    worksheet[6][2].change_contents(estimate.customer.phone)
    # Email Address
    worksheet[7][2].change_contents(estimate.customer.email)
    # Address
    address = estimate.customer&.address&.full_address || estimate.site.full_address
    worksheet[8][2].change_contents(address)

    arborist = estimate.arborist

    if estimate.work_date.present?
      # Completion Date
      worksheet[4][7].change_contents(estimate.work_date.strftime("%d/%m/%Y"))
    end

    if arborist.present?
      # Arborist Name
      worksheet[5][7].change_contents(arborist.name)
      # Arborist Cert
      worksheet[6][7].change_contents(arborist.certification)
      # Arborist Phone
      worksheet[7][7].change_contents(arborist.phone_number)
      # Arborist Email
      worksheet[8][7].change_contents(arborist.email)
    end

    estimate.costs.summary_order.each_with_index do |cost, i|
      worksheet[10 + i][0].change_contents(cost.description)
      worksheet[10 + i][7].change_contents(cost.amount.to_f)
    end

    worksheet[19][7].change_contents("$#{sprintf("%.2f", estimate.total_cost.to_f)}")
    worksheet[20][7].change_contents("$#{sprintf("%.2f", estimate.hst.to_f)}")
    worksheet[22][7].change_contents("$#{sprintf("%.2f", estimate.total_cost_with_tax)}")

    workbook.write(destination)
    
    return destination
  end
end
