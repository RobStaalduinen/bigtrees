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
    # Page margins are set to zero deliberately: the inset is owned by
    # `.page { padding: ... }` in pdf_styles.scss, so there is one place that
    # controls it. Without this wkhtmltopdf adds its own ~10mm on every side on
    # top of the CSS padding, which stacked to roughly an inch.
    pdf = WickedPdf.new.pdf_from_string(
      pdf_html,
      page_size: 'Letter',
      margin: { top: 0, bottom: 0, left: 0, right: 0 }
    )
    save_path = Rails.root.join('tmp', "Quote_#{estimate.id}.pdf")
    File.open(save_path, 'wb') do |file|
      file << pdf
    end
    save_path.to_s

  end
end
