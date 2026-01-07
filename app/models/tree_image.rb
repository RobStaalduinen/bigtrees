class TreeImage < ActiveRecord::Base
  BUCKET_URL = 'https://bigtreecare.s3.amazonaws.com'
  IMGIX_CDN = 'https://bigtrees.imgix.net'
  belongs_to :tree
  belongs_to :estimate

  def url
    image_url
  end

  def imgix_url
    url.gsub(BUCKET_URL, IMGIX_CDN).split('?')[0]
  end

  def edited_imgix_url
    return nil unless edited_image_url

    edited_image_url
    # edited_image_url.gsub(BUCKET_URL, IMGIX_CDN).split('?')[0]
  end

  def generate_image_name
    e_id = self.tree.try(:estimate_id) || "-"
    t_id = self.tree_id || "-"
    "Estimate_#{e_id}_Tree_#{t_id}_Image_#{self.id}"
  end

  # def image_url_sm
  #   # "#{imgix_url}?w=400"
  #   image_url
  # end

  # def image_url_md
  #   # "#{imgix_url}?w=800"
  #   image_url
  # end

  # def edited_image_url_sm
  #   return nil unless edited_imgix_url

  #   # "#{edited_imgix_url}?w=400"
    
  #   edited_imgix_url
  # end

  # def edited_image_url_md
  #   return nil unless edited_imgix_url

  #   # "#{edited_imgix_url}?w=800"
    
  #   edited_imgix_url
  # end
end
