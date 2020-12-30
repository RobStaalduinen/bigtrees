# frozen_string_literal: true

class InvoicePreviewSerializer < ApplicationSerializer
  attribute :potential_number

  def potential_number
    object.number || object.potential_number
  end
end
