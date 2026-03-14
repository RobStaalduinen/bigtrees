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
include ActionDispatch::TestProcess

FactoryBot.define do
  factory :document do
    name          { 'Test Document' }
    file          { fixture_file_upload(Rails.root.join("spec", "fixtures", "files", "test_file.pdf"),'application/pdf') }
  end
end
