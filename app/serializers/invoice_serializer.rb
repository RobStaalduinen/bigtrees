# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id             :integer          not null, primary key
#  estimate_id    :integer
#  number         :string(255)
#  payment_method :string(255)
#  paid           :boolean          default(FALSE)
#  discount       :boolean          default(FALSE)
#  sent_at        :date
#  paid_at        :date
#
class InvoiceSerializer < ApplicationSerializer
  attribute :number
  attribute :payment_method
  attribute :paid
  attribute :sent_at
  attribute :paid_at
end
