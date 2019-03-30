class Estimate < ActiveRecord::Base
	attr_accessible *column_names

	SIGN_DISCOUNT_MESSAGE = 'Discount for Sign Placement'
	SIGN_DISCOUNT = -25.0

	before_save :set_status

	has_many :trees
	belongs_to :arborist

	scope :submitted, -> { incomplete.where(submission_completed: true).where(cancelled_at: nil) }
	scope :incomplete, -> { where.not(status: 8) }
	scope :complete, -> { where(status: 8) }

	enum status: { 
		needs_costs: 0,
		needs_arborist: 1,
		pending_quote: 2,
		quote_sent: 3, 
		quote_accepted: 4, 
		work_scheduled: 5,
		work_completed: 6,
		payment_finalized: 7,
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

	def quote_accepted?
		self.quote_accepted_date.present?
	end

	def work_scheduled?
		self.work_date.present?
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
		extra = self.extra_cost || 0.0
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
		self.invoice_number.present?
	end

	def completed?
		self.final_invoice_sent_at.present?
	end

	def self.next_invoice_number
		(Estimate.select("invoice_number").order("estimates.invoice_number DESC").first.invoice_number || 19207) + 1
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
		elsif(self.quote_sent? && !self.quote_accepted?)
			:quote_sent
		elsif(self.quote_accepted? && !self.work_scheduled?)
			:quote_accepted
		elsif(self.work_scheduled? && !self.payment_finalized?)
			:work_scheduled
		elsif(self.payment_finalized? && !self.completed?)
			:payment_finalized
		elsif(self.completed?)
			:completed
		end

		self.status =  new_status
	end
end
