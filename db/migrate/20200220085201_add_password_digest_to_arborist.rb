class AddPasswordDigestToArborist < ActiveRecord::Migration[5.2]
  def change
    add_column :arborists, :password_digest, :string
  end
end
