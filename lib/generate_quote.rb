require 'rubyXL'
require 'rubyXL/convenience_methods'

class GenerateQuote

  def self.call(estimate)
    pdf_html = ActionController::Base.new.render_to_string('quotes/pdf/main.html.erb', layout: 'pdf', locals: { estimate: estimate })
    pdf = WickedPdf.new.pdf_from_string(pdf_html, page_size: 'Letter')
    save_path = Rails.root.join('tmp', "Quote_#{estimate.id}.pdf")
    File.open(save_path, 'wb') do |file|
      file << pdf
    end
    save_path.to_s

  end
end
