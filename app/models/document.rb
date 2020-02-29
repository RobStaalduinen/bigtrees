class Document < ActiveRecord::Base
  belongs_to :arborist

  has_attached_file :file

  validates :name, presence: true
  validates_attachment_presence :file

  validates_attachment_content_type :file, :content_type => ["application/pdf", "application/x-pdf", "image/png", "image/gif", "image/jpg", "image/jpeg"]
end
