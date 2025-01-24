class Estimate < ActiveRecord::Base

	SIGN_DISCOUNT_MESSAGE = 'Discount for Sign Placement'
	SIGN_DISCOUNT = -25.0

	TAX_RATE = 0.13

	before_save :set_status

	has_many :trees, dependent: :destroy
	has_many :tree_images, dependent: :destroy
	has_many :extra_costs, dependent: :destroy
  has_many :costs, dependent: :destroy
  has_many :notes, dependent: :destroy

  has_many :equipment_assignments, dependent: :destroy
  has_many :vehicles, through: :equipment_assignments

	has_many :taggings, dependent: :destroy
	has_many :tags, through: :taggings

	has_one :invoice, dependent: :destroy
  has_one :site, dependent: :destroy
  has_one :customer_detail, dependent: :destroy

	belongs_to :customer
	belongs_to :arborist
  belongs_to :organization

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
  scope :cancelled, -> { where(cancelled_at: nil) }
	scope :pending_payment, -> { active.final_invoice_sent }
	scope :complete, -> { where(status: 8) }
	scope :today, -> { incomplete.where(work_start_date: Date.today) }
	scope :active, -> { where(is_unknown: false).where("status < 8") }
  scope :no_followup, -> { where(followup_sent_at: nil) }
	scope :unknown, -> { where(is_unknown: true) }
	scope :paid, -> { joins(:invoice).where(invoices: { paid: true }).uniq }
  scope :with_customer, -> { where.not(customer: nil) }
  scope :pre_quote, -> { (price_required.or(pending_quote)).active }

  # Filters
  scope :created_after, -> (filter_string) do
    case filter_string
    when 'one_week'
      where('estimates.created_at >= ?', Date.today - 1.week)
    when 'one_month'
      where('estimates.created_at >= ?', Date.today - 1.month)
    when 'six_months'
      where('estimates.created_at >= ?', Date.today - 6.months)
    when 'one_year'
      where('estimates.created_at >= ?', Date.today - 1.year)
    else
      all
    end
  end



  scope :for_status, -> (filter_string) do
    case filter_string
    when 'active'
      submitted.all.active.no_followup
    when 'needs_pricing'
      submitted.price_required.active
    when 'pre_quote'
      submitted.pre_quote
    when 'awaiting_response'
      submitted.sent.active
    when 'to_pay'
      submitted.pending_payment.active
    when 'scheduled'
      submitted.scheduled.active
    when 'unknown'
      submitted.unknown
    when 'cancelled'
      cancelled
    else
      all
    end
  end


	enum status: {
		needs_costs: 0,
		needs_arborist: 1,
		pending_quote: 2,
		quote_sent: 3,
		pending_permit: 4,
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
    return 'Picture Request Sent' if read_attribute(:status).to_i < 4 && picture_request_sent_at.present?
    return 'No Response Followup Sent' if read_attribute(:status).to_i < 4 && followup_sent_at.present?
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

  def quote_display_address
    return site.full_address unless invoice&.number.present?

    customer_detail&.address&.full_address || site.full_address
  end

	def pdf_quote
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
		elsif(self.quote_sent? && !self.work_scheduled? && !self.pending_permit)
			:quote_sent
    elsif(self.quote_sent? && self.pending_permit)
      :pending_permit
		elsif(self.work_scheduled? && !self.invoice.sent?)
			:work_scheduled
		elsif(self.invoice.sent? && !self.invoice.paid?)
			:final_invoice_sent
		elsif(self.invoice.paid?)
			:completed
    end

    # self.is_unknown = false if new_status != self.status
    if new_status.to_sym != self.status.to_sym && new_status.to_sym != :cancelled
      self.picture_request_sent_at = nil
      self.followup_sent_at = nil
    end

		process_tags(new_status)

		self.status = new_status

		self.save! if save
  end

	def process_tags(new_status)
		if %w[needs_arborist pending_quote].include?(new_status.to_s)
			self.taggings.joins(:tag).where(tags: { label: 'Site Visit' }).destroy_all
		end
	end

  def site_visit_required
    status.to_s == 'needs_costs' && site_visit
  end

	def add_system_tag(tag_name)
		tag = organization.tags.find_by(label: tag_name)
		self.taggings.create(tag: tag)
	end
end
