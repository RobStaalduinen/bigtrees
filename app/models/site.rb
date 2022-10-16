class Site < ActiveRecord::Base
  include SingleAddressable

  belongs_to :estimate
  has_many :trees, through: :estimate

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
