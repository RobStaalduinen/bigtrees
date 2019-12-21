class Invoice < ActiveRecord::Base
  include StatusDriver
  
  belongs_to :estimate

  def is_final?
    self.number.present?
  end
  
  def sent?
    self.sent_at.present?
  end

  def assign_number
		self.number = self.potential_number unless self.number.present?
  end
  
  def potential_number
		already_completed_count = Estimate.where(work_date: estimate.work_date).joins(:invoice).count
		date_string = estimate.work_date.strftime("%y%m%d")

		return "#{date_string}#{already_completed_count + 1}"
  end
  
  def pdf_receipt
    estimate = self.estimate
    receipt_file = GenerateReceipt.call(estimate)
    destination = Rails.root.join("tmp", "Receipt_Estimate_#{estimate.id}__PDF.pdf")
    Libreconv.convert(receipt_file.to_s, destination.to_s)
    return destination.to_s
  end

  def pdf_receipt_fle_name
		"Receipt-#{self.estimate.invoice.number}.pdf"
  end
  
end
