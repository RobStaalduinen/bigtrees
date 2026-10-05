# frozen_string_literal: true

# == Schema Information
#
# Table name: nylas_accounts
#
#  id                     :bigint           not null, primary key
#  organization_id        :bigint           not null
#  outgoing_email_address :string(255)
#  code                   :string(255)
#  grant_id               :string(255)
#  raw_response           :json
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  status                 :string(255)      default("active"), not null
#
class NylasAccount < ActiveRecord::Base
  belongs_to :organization

  enum :status, { active: 'active', unsynced: 'unsynced', insufficient: 'insufficient' }

  # Which Nylas application owns this grant. A grant is only usable with the
  # credentials of the application that created it, so this drives which
  # Wrapper (and therefore which client_id/api_key) every call uses.
  # Prefixed so the predicates do not collide with the status enum's.
  enum :nylas_application, { production: 'production', sandbox: 'sandbox' }, prefix: true

  # Mailers check only for the presence of an organization's nylas_account
  # before sending, so a row without a grant reads as a working connection.
  # Never let one be written.
  validates :grant_id, presence: true

  # Re-checks the grant with Nylas and persists the result. Returns the status
  # rather than raising, so the caller can report it.
  def refresh_status!
    Nylas::Wrapper.for(self).refresh_status(self)
  end
end
