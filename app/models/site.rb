# == Schema Information
#
# Table name: sites
#
#  id                :integer          not null, primary key
#  estimate_id       :integer
#  street            :string(255)
#  city              :string(255)
#  wood_removal      :boolean          default(TRUE)
#  vehicle_access    :boolean          default(FALSE)
#  breakables        :boolean          default(FALSE)
#  access_width      :string(255)
#  cleanup           :boolean          default(FALSE)
#  address_id        :integer
#  low_access_width  :boolean          default(FALSE)
#  survey_filled_out :boolean          default(FALSE)
#  visit_consent     :boolean          default(FALSE)
#  visit_times       :text(65535)
#
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
