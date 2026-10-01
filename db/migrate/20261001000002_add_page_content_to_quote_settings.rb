class AddPageContentToQuoteSettings < ActiveRecord::Migration[8.0]
  # Editable copy for the "Before we start" and "Terms and conditions" pages.
  #
  # Deliberately NOT backfilled. Null means "use the stock copy", which is what
  # every organization gets today, and Organization#quote_pre_job_html /
  # #quote_terms_html resolve that. Writing a copy into every row instead would
  # freeze each organization's text at today's wording, so a later correction to
  # the stock terms would never reach anyone.
  def change
    add_column :quote_settings, :pre_job_content, :text
    add_column :quote_settings, :terms_content, :text
  end
end
