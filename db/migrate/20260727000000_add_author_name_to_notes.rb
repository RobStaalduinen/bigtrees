class AddAuthorNameToNotes < ActiveRecord::Migration[8.0]
  def up
    add_column :notes, :author_name, :string

    # Snapshot the current author's name onto every existing note so the
    # displayed author stays fixed to who wrote it (previously derived live
    # from the arborist association).
    execute(<<~SQL.squish)
      UPDATE notes
      INNER JOIN arborists ON arborists.id = notes.arborist_id
      SET notes.author_name = arborists.name
    SQL
  end

  def down
    remove_column :notes, :author_name
  end
end
