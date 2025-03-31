class AddCrewMemberToArborist < ActiveRecord::Migration[6.0]
  def change
    add_column :arborists, :crew_member, :boolean, default: true
  end
end
