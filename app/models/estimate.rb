class Estimate < ActiveRecord::Base

	SIGN_DISCOUNT_MESSAGE = 'Discount for Sign Placement'
	SIGN_DISCOUNT = -25.0

	TAX_RATE = 0.13

	before_save :set_status

	has_many :trees
	has_many :tree_images, through: :trees
	has_many :extra_costs
  has_many :costs
  has_many :notes

  has_many :equipment_assignments
  has_many :vehicles, through: :equipment_assignments

	has_one :invoice
	has_one :site
	belongs_to :customer
	belongs_to :arborist

  accepts_nested_attributes_for :site
  accepts_nested_attributes_for :equipment_assignments
  accepts_nested_attributes_for :notes

	scope :submitted, -> { where(submission_completed: true).where(cancelled_at: nil) }
	scope :incomplete, -> { active.where("status < 4") }
	scope :price_required, -> { active.where("status = 0").where(picture_request_sent_at: nil) }
  scope :sent, -> do
     active.where("
      status = 3 OR
      (status < 4 AND picture_request_sent_at IS NOT NULL AND is_unknown = false) OR
      (status < 4 AND followup_sent_at IS NOT NULL AND is_unknown = false)
    ")
  end
  scope :scheduled, -> { active.where("status >= 4 AND status < 7") }
	scope :pending_payment, -> { active.final_invoice_sent }
	scope :complete, -> { where(status: 8) }
	scope :today, -> { incomplete.where(work_start_date: Date.today) }
	scope :active, -> { where(is_unknown: false) }
	scope :unknown, -> { where(is_unknown: true) }
	scope :paid, -> { joins(:invoice).where(invoices: { paid: true }).uniq }
  scope :with_customer, -> { where.not(customer: nil) }

  # Filters
  scope :created_after, -> (filter_string) do
    case filter_string
    when 'one_week'
      where('estimates.created_at >= ?', Date.today - 1.week)
    when 'one_month'
      where('estimates.created_at >= ?', Date.today - 1.month)
    when 'six_months'
      where('estimates.created_at >= ?', Date.today - 6.months)
    else
      all
    end
  end

  scope :for_status, -> (filter_string) do
    case filter_string
    when 'needs_pricing'
      price_required
    when 'awaiting_response'
      sent
    when 'to_pay'
      pending_payment
    when 'scheduled'
      scheduled
    when 'unknown'
      unknown
    else
      all
    end
  end


	enum status: {
		needs_costs: 0,
		needs_arborist: 1,
		pending_quote: 2,
		quote_sent: 3,
		quote_accepted: 4,
		work_scheduled: 5,
		work_completed: 6,
		final_invoice_sent: 7,
		completed: 8,
		cancelled: 10
  }

	# Associations
	alias :get_invoice :invoice
	def invoice
		get_invoice || Invoice.new(estimate: self)
	end

	def formatted_status
		return "Invoice Sent" if status == 'final_invoice_sent'
		self.status.gsub('_', ' ').capitalize
	end

	def additional_message
    return 'Picture Request Sent' if read_attribute(:status) < 4 && picture_request_sent_at.present?
    return 'No Response Followup Sent' if read_attribute(:status) < 4 && followup_sent_at.present?
	end

	def quote_sent?
		self.quote_sent_date.present?
	end

	def arborist?
		self.arborist.present?
	end

	def work_scheduled?
		self.work_start_date.present? || self.skip_schedule
	end

	def contact_methods
		[self.customer.phone, self.customer.email].compact.join(" | ")
	end

	def preferred_contact_method
		self.customer.preferred_contact.present? ? self.customer.preferred_contact.capitalize : "None given"
	end

	def total_cost
		self.costs.sum(:amount)
	end

	def hst
		(self.total_cost * TAX_RATE).round(2)
	end

	def total_cost_with_tax
		self.total_cost + self.hst
	end

	def pdf_quote
		# destination = Rails.root.join("tmp", "Quote__Estimate_#{self.id}__PDF.pdf")
		# Libreconv.convert(estimate_file.to_s, destination.to_s)
    # return destination.to_s

    GenerateQuote.call(self)
	end

	def pdf_file_name
		base_name = "#{self.customer.first_name}-#{self.site.address&.street}-#{self.site.address&.city}".gsub('.', '').gsub('\/', '')
		"#{base_name}.pdf"
	end

	def unknown?
		self.is_unknown
	end

	def final?
		self.invoice.present? && self.invoice.paid?
	end

	def can_resend_quote?
		true
	end

	def paid?
		self.invoice && self.invoice.paid?
	end

	def outstanding_amount
		self.paid? ? 0.0 : self.total_cost
	end

	def set_status(save = false)
		new_status = if(self.cancelled_at.present?)
			:cancelled
		elsif(!self.costs.any?)
			:needs_costs
		elsif(self.costs.any? && !self.arborist?)
			:needs_arborist
		elsif(self.arborist? && !self.quote_sent?)
			:pending_quote
		elsif(self.quote_sent? && !self.work_scheduled?)
			:quote_sent
		elsif(self.work_scheduled? && !self.invoice.sent?)
			:work_scheduled
		elsif(self.invoice.sent? && !self.invoice.paid?)
			:final_invoice_sent
		elsif(self.invoice.paid?)
			:completed
    end

    # self.is_unknown = false if new_status != self.status
		self.status = new_status

		self.save! if save
  end

end
