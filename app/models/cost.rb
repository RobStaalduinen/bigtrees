class Cost < ActiveRecord::Base
  belongs_to :estimate

  SIGN_DISCOUNT_MESSAGE = 'Discount for Sign Placement'
  SIGN_DISCOUNT = -25.0

  default_scope { order("discount, id") }

  scope :summary_order, -> { order("discount, id") }
  scope :discount, -> { where(discount: true) }
  scope :charge, -> { where(discount: false) }

  before_save :set_discount

  def self.json_cost(description, amount)
    {
      description: description,
      amount: amount
    }
  end

  def self.create_sign_discount(estimate)
    return if estimate.costs.where(description: SIGN_DISCOUNT_MESSAGE).any?

    estimate.costs.create(
      description: SIGN_DISCOUNT_MESSAGE,
      amount: SIGN_DISCOUNT,
      discount: true
    )
  end

  def set_discount
    self.discount = true if amount.to_f < 0.0
  end
end
