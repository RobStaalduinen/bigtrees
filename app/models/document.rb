# == Schema Information
#
# Table name: documents
#
#  id                :integer          not null, primary key
#  arborist_id       :integer
#  name              :string(255)
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer
#  file_updated_at   :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  expires_at        :date
#  url               :string(255)
#
class Document < ActiveRecord::Base
  belongs_to :arborist

  def file_url
    self.url
  end

  validates :name, presence: true
end
