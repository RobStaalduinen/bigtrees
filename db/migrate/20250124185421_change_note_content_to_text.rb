class ChangeNoteContentToText < ActiveRecord::Migration[6.0]
  def change
    change_column :notes, :content, :text
  end
end
