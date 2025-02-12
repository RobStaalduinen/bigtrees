class Document < ActiveRecord::Base
  belongs_to :arborist

  def file_url
    self.url
  end

  validates :name, presence: true
end
