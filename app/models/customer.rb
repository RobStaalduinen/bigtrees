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
    estimates.order('id DESC').first&.id
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
end
