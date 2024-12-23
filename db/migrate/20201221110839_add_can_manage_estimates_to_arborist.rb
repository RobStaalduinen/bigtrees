class AddCanManageEstimatesToArborist < ActiveRecord::Migration[5.2]
  def change
    add_column :arborists, :can_manage_estimates, :boolean, default: false

    Arborist.where(id: [2, 5]).update_all(can_manage_estimates: true)
  end
end
