class CreateQuoteSettings < ActiveRecord::Migration[8.0]
  # Per-organization control over which optional pages a quote PDF carries.
  #
  # All three default to TRUE: every existing quote includes all three pages,
  # so the defaults have to preserve that behaviour for organizations that
  # never touch this screen.
  def change
    create_table :quote_settings do |t|
      t.references :organization, null: false, index: { unique: true }
      t.boolean :include_image_page,   null: false, default: true
      t.boolean :include_pre_job_page, null: false, default: true
      t.boolean :include_terms,        null: false, default: true

      t.timestamps
    end
  end
end
