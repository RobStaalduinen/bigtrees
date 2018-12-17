class Estimate < ActiveRecord::Base
	attr_accessible *column_names

	has_many :tree_images

	scope :submitted, -> { where(submission_completed: true) }

	enum status: { 
		needs_costs: 0,
		quote_sent: 1, 
		quote_accepted: 2, 
		work_scheduled: 3,
		work_completed: 4
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
end
