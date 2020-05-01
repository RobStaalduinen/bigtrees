class CreateArborist < ActiveRecord::Migration
  def change
    create_table :arborists do |t|
      t.string :name, null: false
      t.string :certification, null: false
    end
  end
end
