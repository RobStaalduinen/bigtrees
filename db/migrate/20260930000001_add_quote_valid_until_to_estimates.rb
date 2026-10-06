class AddQuoteValidUntilToEstimates < ActiveRecord::Migration[8.0]
  # Optional quote expiry. Lives on estimates alongside the other quote dates
  # (quote_sent_date, quote_accepted_date) rather than on quote_scopes, which
  # holds the scope prose.
  def change
    add_column :estimates, :quote_valid_until, :date
  end
end
