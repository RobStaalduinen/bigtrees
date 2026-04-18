# == Schema Information
#
# Table name: customers
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  email             :string(255)
#  phone             :string(255)
#  preferred_contact :string(255)
#  address_id        :integer
#  short_name        :string(255)
#
class Customer < ActiveRecord::Base
  include SingleAddressable

  has_many :estimates

  before_save :downcase_fields

  scope :with_name, -> { where.not(name: [nil, ""]) }

  def self.find_or_create_by_params(params)
    customer = Customer.find_by(email: params[:email]) if params[:email].present?

    if customer.blank?
      customer = Customer.create(params)
    end

    customer
  end

  # def serialized
  #   slice(:id, :name, :phone, :email, :preferred_contact).merge({ address: address&.serialized })
  # end

  def recent_estimate_id
    last_estimate&.id
  end

  def customer_address
     address&.slice(:street, :city)
  end

  def site_address
    estimate = estimates.joins(:site).last
    if estimate.present? && estimate.site.present?
      estimate.site.address&.slice(:street, :city)
    end
  end

  def first_name
		self.name.split(" ")[0]
	end

  def contact_list
    [self.email, self.phone].compact.join("  |  ")
  end

  def preferred_method
    (self.preferred_contact || "").capitalize
  end

  def downcase_fields
    self.email&.downcase!
  end

  def estimate_count
    estimates.size
  end

  def formatted_address
    return nil unless address.present?
    [address.street, address.city, address.postal_code].compact.reject(&:empty?).join(', ').presence
  end

  def last_estimate_status
    last_estimate&.formatted_status
  end

  def last_activity_date
    last_estimate&.created_at&.to_date
  end

  private

  def last_estimate
    @last_estimate ||= estimates.max_by(&:id)
  end
end
