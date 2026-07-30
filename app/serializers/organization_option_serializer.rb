# frozen_string_literal: true

# Lightweight organization payload for pickers (e.g. the transfer-target
# dropdown). Avoids the heavy OrganizationSerializer, which loads YAML feature
# templates per record.
class OrganizationOptionSerializer < ApplicationSerializer
  attribute :name
end
