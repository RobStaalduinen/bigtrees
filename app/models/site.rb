class Site < ActiveRecord::Base
  belongs_to :estimate
  has_many :trees, through: :estimate

  belongs_to :address
  accepts_nested_attributes_for :address, allow_destroy: true

  def serialized
    slice(:street, :city, :wood_removal, :vehicle_access, :breakables, :cleanup).merge(
      { street: address.street, city: address.city, full_address: full_address }.compact
    )
  end

  def answer_for(attribute)
		self[attribute] ? "Yes" : "No"
  end

  def full_address
    if address.present?
      address.full_address
    else
      [street, city].join(", ")
    end
  end

  def should_display_access?
		self.trees.stumping_possible.any? && self.trees.pluck(:in_backyard).any?
  end

end
