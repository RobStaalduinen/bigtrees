class Customer < ActiveRecord::Base
  has_many :estimates
  belongs_to :address
  accepts_nested_attributes_for :address

  before_save :downcase_fields

  scope :with_name, -> { where.not(name: [nil, ""]) }

  def self.find_or_create_by_params(params)
    customer = Customer.find_by(email: params[:email]) if params[:email].present?
    customer = Customer.find_by(email: params[:phone]) if customer.blank? && params[:phone].present?
    customer = Customer.new if customer.blank?
    customer.update(params)
    customer
  end

  def serialized
    slice(:id, :name, :phone, :email, :preferred_contact).merge({ address: address&.serialized })
  end

  def recent_estimate_id
    estimates.order('id DESC').first&.id
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
    self.email.downcase!
  end
end
