require 'rubyXL'
require 'rubyXL/convenience_methods'

class GenerateQuote

  def self.call(estimate)
    compressed_view = estimate.invoice.present? && estimate.invoice.number.present?
    
    pdf_html = ApplicationController.render(
      template: 'quotes/pdf/main',
      layout: 'pdf',
      locals: { estimate: estimate, compressed_view: compressed_view }
    )
    pdf = WickedPdf.new.pdf_from_string(pdf_html, page_size: 'Letter')
    save_path = Rails.root.join('tmp', "Quote_#{estimate.id}.pdf")
    File.open(save_path, 'wb') do |file|
      file << pdf
    end
    save_path.to_s

  end
end
