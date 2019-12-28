class CreateSite < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.belongs_to :estimate, index: true
      t.string :street
      t.string :city
      t.boolean :wood_removal, default: true
      t.boolean :vehicle_access, default: false
      t.boolean :breakables, default: false
      t.string :access_width
    end
  end
end
