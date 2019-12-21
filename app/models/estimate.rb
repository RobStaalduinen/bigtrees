class Estimate < ActiveRecord::Base

	SIGN_DISCOUNT_MESSAGE = 'Discount for Sign Placement'
	SIGN_DISCOUNT = -25.0
	
	before_save :set_status

	has_many :trees
	has_many :extra_costs
	has_one :invoice
	belongs_to :customer
	belongs_to :arborist

	scope :submitted, -> { where(submission_completed: true).where(cancelled_at: nil) }
	scope :incomplete, -> { active.where("status < 3") }
	scope :sent, -> { active.where("status = 3") }
	scope :scheduled, -> { active.where("status >= 4 AND status < 7") }
	scope :pending_payment, -> { active.final_invoice_sent }
	scope :complete, -> { where(status: 8) }
	scope :today, -> { incomplete.where(work_date: Date.today) }
	scope :active, -> { where(is_unknown: false) }
	scope :unknown, -> { where(is_unknown: true) }
	scope :paid, -> { joins(:invoice).where(invoices: { paid: true }).uniq }
	scope :with_customer, -> { where.not(customer: nil) }
	
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

	def formatted_status
		self.status.gsub('_', ' ').capitalize
	end

	def answer_for(attribute)
		self[attribute] ? "Yes" : "No"
	end

	def costs?
		self.trees.pluck(:cost).select{ |c| c == nil }.all?
	end

	def quote_sent?
		self.quote_sent_date.present?
	end

	def arborist?
		self.arborist.present?
	end

	def work_scheduled?
		self.work_date.present?
	end

	def full_address
		[self.street, self.city].join(", ")
	end

	def contact_methods
		[self.customer.phone, self.customer.email].compact.join(" | ")
	end

	def preferred_contact_method
		self.customer.preferred_contact.present? ? self.customer.preferred_contact.capitalize : "None given"
	end

	def total_cost
		extra = self.extra_costs.sum(:amount)
		total_cost = self.trees.sum(:cost) + extra
		total_cost += SIGN_DISCOUNT if self.invoice && self.invoice.discount
		total_cost
	end

	def pdf_quote
		estimate_file = GenerateQuote.call(self)
		destination = Rails.root.join("tmp", "Quote__Estimate_#{self.id}__PDF.pdf")
		Libreconv.convert(estimate_file.to_s, destination.to_s)
		return destination.to_s
	end

	def pdf_file_name
		"#{self.customer.first_name}-#{self.street}-#{self.city}.pdf"
	end

	def unknown?
		self.is_unknown
	end

	def should_display_access?
		self.trees.stumping_possible.any? && self.trees.pluck(:in_backyard).any?
	end

	def can_resend_quote?
		self.quote_sent? && !self.invoice.sent?
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
		elsif(self.trees.any? && !self.costs?)
			:needs_costs
		elsif(self.costs? && !self.arborist?)
			:needs_arborist
		elsif(self.arborist? && !self.quote_sent?)
			:pending_quote
		elsif(self.quote_sent? && !self.work_scheduled?)
			:quote_sent
		elsif(self.work_scheduled? && !self.invoice.present?)
			:work_scheduled
		elsif(self.invoice.present? && !self.invoice.paid?)
			:final_invoice_sent
		elsif(self.invoice.paid?)
			:completed
		end

		self.status = new_status

		self.save! if save
	end
end
