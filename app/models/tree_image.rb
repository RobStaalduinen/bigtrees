class TreeImage < ActiveRecord::Base
  BUCKET_URL = 'https://bigtreecare.s3.amazonaws.com'
  IMGIX_CDN = 'https://bigtrees.imgix.net'
  belongs_to :tree
  belongs_to :estimate

  after_save :update_image_url

  def url
    image_url
  end

  def imgix_url
    url.gsub(BUCKET_URL, IMGIX_CDN).split('?')[0]
  end

  def edited_imgix_url
    return nil unless edited_image_url
    edited_image_url.gsub(BUCKET_URL, IMGIX_CDN).split('?')[0]
  end

  def generate_image_name
    e_id = self.tree.try(:estimate_id) || "-"
    t_id = self.tree_id || "-"
    "Estimate_#{e_id}_Tree_#{t_id}_Image_#{self.id}"
  end

  def image_url_sm
    "#{imgix_url}?w=400"
  end

  def image_url_md
    "#{imgix_url}?w=800"
  end

  def edited_image_url_sm
    return nil unless edited_imgix_url

    "#{edited_imgix_url}?w=400"
  end

  def edited_image_url_md
    return nil unless edited_imgix_url

    "#{edited_imgix_url}?w=800"
  end

  def update_image_url
    return unless image_url.blank? && asset.present?

    self.update_attribute(:image_url, asset.url)
  end
end
