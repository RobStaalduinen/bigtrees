class AddPasswordDigestToArborist < ActiveRecord::Migration
  def change
    add_column :arborists, :password_digest, :string
  end
end
