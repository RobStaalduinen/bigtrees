class AddCategoryToEmailTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :email_templates, :category, :string, default: 'default', null: false
    add_index :email_templates, :category
  end
end
