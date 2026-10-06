class CreateQuoteScopes < ActiveRecord::Migration[8.0]
  # Scope / inclusions / exclusions for the quote PDF. Kept off estimates so the
  # core model doesn't grow three more optional columns most estimates never use
  # — a quote either has this record or it doesn't.
  def change
    create_table :quote_scopes do |t|
      t.references :estimate, null: false, index: { unique: true }
      t.text :scope_of_work
      t.json :inclusions
      t.json :exclusions

      t.timestamps
    end
  end
end
