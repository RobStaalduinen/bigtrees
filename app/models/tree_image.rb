class TreeImage < ActiveRecord::Base
attr_accessible *column_names

  belongs_to :estimate

  has_attached_file :asset, :path =>  "images/:rails_env/:class/:image_name.:content_type_extension"

  Paperclip.interpolates :image_name do |attachment, style|
    "Esimate_#{attachment.instance.estimate_id}_Tree_#{attachment.instance.tree_number}_Image_#{attachment.instance.id}"
  end

  validates_attachment_content_type :asset, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
