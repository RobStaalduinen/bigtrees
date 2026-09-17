class SplitDefaultEmailTemplateCategory < ActiveRecord::Migration[6.0]
  # The 'default' category used to cover every workflow email. Each of these keys now names the
  # point in the workflow it is sent from, so organizations can write their own templates for it.
  CATEGORY_BY_KEY = {
    'quote_mailout' => 'quote',
    'approval_mailout' => 'approval',
    'job_progress' => 'job_progress',
    'invoice_mailout' => 'invoice',
    'receipt_mailout' => 'receipt'
  }.freeze

  def up
    CATEGORY_BY_KEY.each do |key, category|
      EmailTemplate.where(category: 'default', key: key).update_all(category: category)
    end

    # Only the keys above were ever seeded as 'default', but anything left behind would fail the
    # model's category validation and become uneditable — send it through the generic quote step.
    EmailTemplate.where(category: 'default').update_all(category: 'quote')

    change_column_default :email_templates, :category, nil
  end

  def down
    change_column_default :email_templates, :category, 'default'

    EmailTemplate.where(category: CATEGORY_BY_KEY.values).update_all(category: 'default')
  end
end
