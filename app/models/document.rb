class Document < ActiveRecord::Base
  belongs_to :arborist

  has_attached_file :file

  def file_url
    # Replace with more basic uploader
    self.url || self.file.url
  end

  validates :name, presence: true
end
