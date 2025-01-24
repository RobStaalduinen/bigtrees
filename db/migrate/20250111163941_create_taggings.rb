class CreateTaggings < ActiveRecord::Migration[6.0]
  def change
    create_table :taggings do |t|
      t.belongs_to :estimate, index: true
      t.belongs_to :tag, index: true

      t.timestamps null: false
    end


    Estimate.where(site_visit_tag: true).each do |estimate|
      tag = estimate.organization.tags.find_by(label: 'Site Visit')
      estimate.taggings.create(tag: tag)
    end
  end
end
