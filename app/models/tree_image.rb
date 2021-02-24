class TreeImage < ActiveRecord::Base
  BUCKET_URL = 'https://bigtreecare.s3.amazonaws.com'
  IMGIX_CDN = 'http://bigtrees.imgix.net'
  belongs_to :tree

  # has_attached_file :asset, :path =>  "images/:rails_env/:class/:image_name.:content_type_extension"
  has_attached_file :asset, :path =>  "images/production/:class/:image_name.:content_type_extension"

  Paperclip.interpolates :image_name do |attachment, style|
    attachment.instance.generate_image_name
  end

  def url
    image_url || asset.url
  end

  def imgix_url
    url.gsub(BUCKET_URL, IMGIX_CDN).split('?')[0]
  end

  def edited_imgix_url
    return nil unless edited_image_url
    edited_image_url.gsub(BUCKET_URL, IMGIX_CDN).split('?')[0]
  end

  def generate_image_name
    e_id = self.tree.try(:estiamte_id) || "-"
    t_id = self.tree_id || "-"
    "Estimate_#{e_id}_Tree_#{t_id}_Image_#{self.id}"
  end

  def image_url_sm
    "#{imgix_url}?w=400"
  end

  def image_url_md
    "#{imgix_url}?w=800"
  end

  def edited_image_url_md
    return nil unless edited_imgix_url
    "#{edited_imgix_url}?w=800"
  end

  validates_attachment_content_type :asset, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
