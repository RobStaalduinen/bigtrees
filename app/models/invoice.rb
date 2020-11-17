class Invoice < ActiveRecord::Base
  include StatusDriver

  belongs_to :estimate

  def serialized
    slice(:id, :number, :payment_method, :sent_at, :paid_at)
  end

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
    GenerateReceipt.call(estimate)
  end

  def pdf_receipt_fle_name
		"Receipt-#{self.estimate.invoice.number}.pdf"
  end

end
