class AddCategoryToEmailTemplates < ActiveRecord::Migration[6.0]
  def up
    unless column_exists?(:email_templates, :category)
      add_column :email_templates, :category, :string, default: 'default', null: false
    end

    unless index_exists?(:email_templates, :category)
      add_index :email_templates, :category
    end
  end

  def down
    remove_column :email_templates, :category if column_exists?(:email_templates, :category)
  end
end
