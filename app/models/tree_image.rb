class TreeImage < ActiveRecord::Base
  belongs_to :tree

  has_attached_file :asset, :path =>  "images/:rails_env/:class/:image_name.:content_type_extension"

  Paperclip.interpolates :image_name do |attachment, style|
    attachment.instance.generate_image_name
  end

  def generate_image_name
    e_id = self.tree.try(:estiamte_id) || "-"
    t_id = self.tree_id || "-"
    "Estimate_#{e_id}_Tree_#{t_id}_Image_#{self.id}"
  end

  validates_attachment_content_type :asset, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
