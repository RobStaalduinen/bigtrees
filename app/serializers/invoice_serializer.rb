# frozen_string_literal: true

class InvoiceSerializer < ApplicationSerializer
  attribute :number
  attribute :payment_method
  attribute :paid
  attribute :sent_at
  attribute :paid_at
end
