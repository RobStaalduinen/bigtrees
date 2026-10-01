class AddFooterTextToQuoteSettings < ActiveRecord::Migration[8.0]
  # Free-text footer for the quote PDF, replacing the hardcoded insurance/HST
  # line. Backfilled with exactly what each organization's footer renders today
  # (via Organization#default_quote_footer_text) so nobody's quote changes on
  # deploy — they can then edit it.
  def up
    add_column :quote_settings, :footer_text, :text

    Organization.find_each do |organization|
      text = organization.default_quote_footer_text
      next if text.blank?

      settings = organization.quote_settings || organization.build_quote_settings
      settings.footer_text = text
      settings.save!
    end
  end

  def down
    remove_column :quote_settings, :footer_text
  end
end
