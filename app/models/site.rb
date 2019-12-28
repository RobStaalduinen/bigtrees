class Site < ActiveRecord::Base
  belongs_to :estimate
  has_many :trees, through: :estimate

  def answer_for(attribute)
		self[attribute] ? "Yes" : "No"
  end
  
  def full_address
		[self.street, self.city].join(", ")
  end
  
  def should_display_access?
		self.trees.stumping_possible.any? && self.trees.pluck(:in_backyard).any?
  end
  
end
