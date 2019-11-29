class Estimate < ActiveRecord::Base
	attr_accessible *column_names

	SIGN_DISCOUNT_MESSAGE = 'Discount for Sign Placement'
	SIGN_DISCOUNT = -25.0

	before_save :set_status

	has_many :trees
	has_many :extra_costs
	belongs_to :arborist

	scope :submitted, -> { where(submission_completed: true).where(cancelled_at: nil) }
	scope :incomplete, -> { active.where("status < 7") }
	scope :pending_payment, -> { active.final_invoice_sent }
	scope :complete, -> { where(status: 8) }
	scope :today, -> { incomplete.where(work_date: Date.today) }
	scope :active, -> { where(is_unknown: false) }
	scope :unknown, -> { where(is_unknown: true) }
	scope :paid, -> { where.not(payment_method: nil) }
	
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

	def phone_or_email
		self.email.present? ? self.email : self.phone
	end

	def answer_for(attribute)
		self[attribute] ? "Yes" : "No"
	end

	def costs?
		self.trees.pluck(:cost).select{ |c| c == nil}.all?
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

	def final_invoice_sent?
		self.final_invoice_sent_at.present?
	end

	def full_address
		[self.street, self.city].join(", ")
	end

	def contact_methods
		[self.phone, self.email].compact.join(" | ")
	end

	def preferred_contact_method
		self.preferred_contact.present? ? self.preferred_contact.capitalize : "None given"
	end

	def total_cost
		extra = self.extra_costs.sum(:amount)
		total_cost = self.trees.sum(:cost) + extra
		total_cost += SIGN_DISCOUNT if self.discount_applied
		total_cost
	end

	def first_name
		self.person_name.split(" ")[0]
	end

	def pdf_quote
		estimate_file = GenerateQuote.call(self)
		destination = Rails.root.join("tmp", "Quote__Estimate_#{self.id}__PDF.pdf")
		Libreconv.convert(estimate_file.to_s, destination.to_s)
		return destination.to_s
	end

	def pdf_file_name
		"#{self.first_name}-#{self.street}-#{self.city}.pdf"
	end

	def payment_finalized?
		self.payment_method.present?
	end

	def unknown?
		self.is_unknown
	end

	def potential_invoice_number
		return nil if !self.work_scheduled?

		already_completed_count = Estimate.where(work_date: self.work_date).where.not(invoice_number: nil).count

		date_string = self.work_date.strftime("%y%m%d")

		return "#{date_string}#{already_completed_count + 1}"
	end

	def assign_invoice_number
		return if self.invoice_number.present?
		self.update(invoice_number: self.potential_invoice_number)
	end

	def should_display_access?
		self.trees.stumping_possible.any? && self.trees.pluck(:in_backyard).any?
	end

	def can_resend_quote?
		self.quote_sent? && !self.final_invoice_sent?
	end

	def paid?
		self.payment_method.present?
	end

	def outstanding_amount
		self.paid? ? 0.0 : self.total_cost
	end
	
	def set_status
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
		elsif(self.work_scheduled? && !self.final_invoice_sent?)
			:work_scheduled
		elsif(self.final_invoice_sent? && !self.payment_finalized?)
			:final_invoice_sent
		elsif(self.payment_finalized?)
			:completed
		end

		self.status =  new_status
	end
end
