class Document < ActiveRecord::Base
  belongs_to :arborist

  has_attached_file :file

  def file_url
    # Replace with more basic uploader
    self.file.url
  end

  validates :name, presence: true
  validates_attachment_presence :file

  validates_attachment_content_type :file, :content_type => ["application/pdf", "application/x-pdf", "image/png", "image/gif", "image/jpg", "image/jpeg"]
end
