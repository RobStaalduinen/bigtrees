class RemoveNullConstaintFromCertification < ActiveRecord::Migration[5.2]
  def change
    change_column_null :arborists, :certification, true
  end
end
