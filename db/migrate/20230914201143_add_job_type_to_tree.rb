class AddJobTypeToTree < ActiveRecord::Migration[5.2]
  def change
    add_column :trees, :job_type, :string, index: true

    Tree.find_each do |tree|
      tree.update(job_type: tree.work_type)
    end
  end
end
