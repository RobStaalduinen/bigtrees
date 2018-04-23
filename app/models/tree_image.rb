class TreeImage < ActiveRecord::Base
attr_accessible *column_names

  belongs_to :estimate

  has_attached_file :asset, :path =>  "images/:rails_env/:class/:image_name.:content_type_extension"

  def image_name
    "Esimate_#{self.estimate_id}_Tree_#{self.tree_number}_#{Random.new.rand(10000)}"
  end

  validates_attachment_content_type :asset, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
