# frozen_string_literal: true

module Organizations
  class Stats
    RECENT_DAYS = 14

    def self.call(organizations)
      new(organizations).call
    end

    def initialize(organizations)
      @organizations = organizations
      @cutoff = RECENT_DAYS.days.ago
    end

    def call
      @organizations.map { |org| stats_for(org) }
    end

    private

    def stats_for(org)
      {
        id: org.id,
        estimates: counts(org.estimates),
        invoices: invoice_counts(org),
        receipts: counts(org.receipts),
        work_records: counts(org.work_records)
      }
    end

    def counts(relation)
      {
        total: relation.count,
        recent: relation.where(created_at: @cutoff..).count
      }
    end

    def invoice_counts(org)
      base = Invoice.joins(:estimate).where(estimates: { organization_id: org.id })
      {
        total: base.count,
        recent: base.where('invoices.created_at >= ?', @cutoff).count
      }
    end
  end
end
