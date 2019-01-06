class Estimate < ActiveRecord::Base
	attr_accessible *column_names

	has_many :trees

	scope :submitted, -> { where(submission_completed: true) }

	enum status: { 
		needs_costs: 0,
		pending_quote: 1,
		quote_sent: 2, 
		quote_accepted: 4, 
		work_scheduled: 5,
		work_completed: 6,
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
		!self.trees.pluck(:cost).select{ |c| c == nil}.any?
	end

	def quote_sent?
		self.quote_sent_date.present?
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

	def set_status
		new_status = if(self.trees.any? && !self.costs?)
			:needs_costs
		elsif(self.costs? && !self.quote_sent?)
			:pending_quote
		elsif(self.quote_sent? && !self.quote_accepted?)
			:quote_sent
		elsif(self.quote_accepted? && !self.work_scheduled?)
			:quote_accepted
		elsif(self.work_scheduled?)
			:work_scheduled
		else
			:work_completed
		end

		self.update(status: new_status)
	end
end
