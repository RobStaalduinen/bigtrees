class Estimate < ActiveRecord::Base

	SIGN_DISCOUNT_MESSAGE = 'Discount for Sign Placement'
	SIGN_DISCOUNT = -25.0

	TAX_RATE = 0.13

	before_save :set_status
	before_save :set_timestamps

	has_many :trees, dependent: :destroy
	has_many :tree_images, dependent: :destroy
  has_many :costs, dependent: :destroy
  has_many :notes, dependent: :destroy

  has_many :equipment_assignments, dependent: :destroy
  has_many :vehicles, through: :equipment_assignments

	has_many :taggings, dependent: :destroy
	has_many :tags, through: :taggings

	has_one :invoice, dependent: :destroy
  has_one :site, dependent: :destroy
  has_one :customer_detail, dependent: :destroy
	has_one :job, dependent: :destroy

	belongs_to :customer
	belongs_to :arborist
  belongs_to :organization

  accepts_nested_attributes_for :site
  accepts_nested_attributes_for :equipment_assignments
  accepts_nested_attributes_for :notes
	accepts_nested_attributes_for :job

	scope :submitted, -> { where(submission_completed: true) }
	scope :incomplete, -> { active.where("status < 40") }
	scope :price_required, -> { active.where("status = 0").where(picture_request_sent_at: nil) }
  scope :sent, -> do
     active.where("
      status = 30 OR
      (status < 40 AND picture_request_sent_at IS NOT NULL) OR
      (status < 40 AND followup_sent_at IS NOT NULL)
    ")
  end
  scope :scheduled, -> { active.where("status >= 40 AND status < 70") }
  # scope :cancelled, -> { where(cancelled_at: nil) }
	scope :pending_payment, -> { active.final_invoice_sent }
	# scope :complete, -> { where(status: 8) }
	scope :today, -> { incomplete.where(work_start_date: Date.today) }
	# scope :active, -> { where(is_unknown: false).where("status < 8") }
	scope :active, -> { in_progress.or(on_hold) }
  scope :no_followup, -> { where(followup_sent_at: nil) }
	# scope :unknown, -> { where(is_unknown: true) }
	scope :paid, -> { joins(:invoice).where(invoices: { paid: true }).uniq }
  scope :with_customer, -> { where.not(customer: nil) }
  scope :pre_quote, -> { (price_required.or(pending_quote)).active }
	scope :approved, -> { where(approved: true) }
	scope :with_tags, ->(tag_ids) do
		joins(:taggings).where(taggings: { tag_id: tag_ids }).distinct
	end

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
			submitted.in_progress.or(submitted.on_hold)
		when 'needs_pricing'
			submitted.in_progress.needs_costs
		when 'pre_quote'
			submitted.in_progress.pre_quote
		when 'awaiting_response'
			submitted.in_progress.sent
		when 'to_pay'
			submitted.in_progress.pending_payment
		when 'scheduled'
			submitted.in_progress.scheduled.or(submitted.in_progress.approved)
		when 'unknown'
			submitted.unknown
		when 'on_hold'
			submitted.on_hold
		when 'completed'
			submitted.done
		when 'cancelled'
			cancelled
    end
  end

	enum state: {
		in_progress: 'in_progress',
		on_hold: 'on_hold',
		done: 'done',
		unknown: 'unknown',
		cancelled: 'cancelled'
	}


	enum status: {
		needs_costs: 0,
		needs_arborist: 10,
		pending_quote: 20,
		quote_sent: 30,
		approved: 40,
		work_scheduled: 50,
		work_started: 55,
		work_completed: 60,
		final_invoice_sent: 70,
		completed: 80
  }

	# Associations
	alias :get_invoice :invoice
	def invoice
		get_invoice || Invoice.new(estimate: self)
	end

	def formatted_status
		return "Invoice Sent" if status == 'final_invoice_sent'
		self.status&.gsub('_', ' ')&.capitalize
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

	def approved?
		self.approved == true
	end

	def contact_methods
		[self.customer.phone, self.customer.email].compact.join(" | ")
	end

	def preferred_contact_method
		self.customer.preferred_contact.present? ? self.customer.preferred_contact.capitalize : "None given"
	end

	def total_cost
		self.costs.sum(:amount).round(2)
	end

	def hst
		(self.total_cost * TAX_RATE).round(2)
	end

	def total_cost_with_tax
		(self.total_cost + self.hst).round(2)
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

	def set_status(save = false, process_state = true)
		old_status = self.status

		new_status = if(!self.costs.any?)
			:needs_costs
		elsif(self.costs.any? && !self.arborist?)
			:needs_arborist
		elsif(self.arborist? && !self.quote_sent?)
			:pending_quote
		elsif(self.quote_sent? && !self.approved?)
			:quote_sent
		elsif(self.approved? && !self.work_scheduled?)
			:approved
		elsif(self.work_scheduled? && !self.job&.skipped? && !self.job&.started?)
			:work_scheduled
		elsif(self.job&.started? && !self.job&.completed?)
			:work_started
		elsif((self.job&.skipped? || self.job&.completed?) && !self.invoice.sent?)
			:work_completed
		elsif(self.invoice.sent? && !self.invoice.paid?)
			:final_invoice_sent
		elsif(self.invoice.paid?)
			:completed
    end

		if new_status == :completed
			self.state = 'done'
			self.state_reason = nil
		end

		if process_state && old_status.present?
			if new_status.to_sym != old_status.to_sym && new_status.to_sym != :cancelled
				self.picture_request_sent_at = nil
				self.followup_sent_at = nil
				if self.state.to_s != 'done'
					self.state = 'in_progress'
					self.state_reason = nil
				end
			end

			# process_tags(old_status, new_status)
		end	

		self.status = new_status

		self.save! if save
	end

	def set_timestamps
		if self.state == 'cancelled'
			self.cancelled_at ||= Time.now
		else
			self.cancelled_at = nil
		end
	end

	# def process_tags(old_status, new_status)
	# 	if %w[needs_arborist pending_quote quote_sent work_scheduled].include?(new_status.to_s) && old_status.to_s != new_status.to_s
	# 		self.taggings.joins(:tag).where(tags: { label: 'Site Visit' }).destroy_all
	# 	end

	# 	if old_status.to_sym != new_status.to_sym
	# 		self.taggings.joins(:tag).where(tags: { label: 'Pending Permit' }).destroy_all
	# 	end
	# end

  def site_visit_required
    status.to_s == 'needs_costs' && site_visit
  end

	def add_system_tag(tag_name)
		tag = organization.tags.find_by(label: tag_name)
		self.taggings.create(tag: tag)
	end
end
