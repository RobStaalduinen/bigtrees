include ActionDispatch::TestProcess

FactoryBot.define do
  factory :document do
    name          { 'Test Document' }
    file          { fixture_file_upload(Rails.root.join("spec", "fixtures", "files", "test_file.pdf"),'application/pdf') }
  end
end
