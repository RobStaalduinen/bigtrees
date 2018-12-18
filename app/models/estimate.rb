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
		!self.trees.pluck(:costs).select{ |c| c == nil}.any?
	end
end
