Paperclip::Attachment.default_options.merge!(
  storage: Rails.env.test? ? :filesystem : :fog,
  fog_credentials: {
    provider: ENV['FOG_PROVIDER'],
    aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    region: ENV['FOG_REGION']
  },
  fog_directory: ENV['FOG_DIRECTORY'],
  bucket: ENV['FOG_DIRECTORY']
)

Paperclip::DataUriAdapter.register
