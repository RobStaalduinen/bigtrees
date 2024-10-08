require 'rubyXL'
require 'rubyXL/convenience_methods'

class GenerateReceipt

  def self.call(estimate)
    pdf_html = ActionController::Base.new.render_to_string('quotes/pdf/main.html.erb', layout: 'pdf', locals: { estimate: estimate, is_receipt: true })
    pdf = WickedPdf.new.pdf_from_string(pdf_html, page_size: 'Letter')
    save_path = Rails.root.join('tmp', "Quote_#{estimate.id}.pdf")
    File.open(save_path, 'wb') do |file|
      file << pdf
    end
    save_path.to_s
    # template = Rails.root.join("lib", "payment_receipt_template.xlsx")
    # destination = Rails.root.join("tmp", "Receipt-Estimate_#{estimate.id}.xlsx")

    # FileUtils.cp(template, destination)

    # workbook = RubyXL::Parser.parse(template)
    # worksheet = workbook[0]

    # invoice = estimate.invoice

    # # Date
    # worksheet[4][2].change_contents(invoice.paid_at.strftime("%d/%m/%Y"))
    # # Customer Name
    # worksheet[5][2].change_contents(estimate.customer.name)
    # # Invoice Number
    # worksheet[6][2].change_contents("##{estimate.invoice.number}")

    # estimate.costs.summary_order.each_with_index do |cost, i|
    #   worksheet[9 + i][0].change_contents(cost.description)
    #   worksheet[9 + i][7].change_contents(cost.amount.to_f)
    # end

    # worksheet[18][7].change_contents("$#{sprintf("%.2f", estimate.total_cost.to_f)}")
    # worksheet[19][7].change_contents("$#{sprintf("%.2f", estimate.hst.to_f)}")
    # worksheet[21][7].change_contents("$#{sprintf("%.2f", estimate.total_cost_with_tax)}")

    # worksheet[23][7].change_contents(invoice.payment_method)

    # workbook.write(destination)

    # return destination
  end
end
