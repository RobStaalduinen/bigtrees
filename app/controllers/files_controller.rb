class FilesController < ApplicationController
  def new
    credentials = Aws::Credentials.new(
      ENV['AWS_ACCESS_KEY_ID'],
      ENV['AWS_SECRET_ACCESS_KEY']
    )

    s3_bucket = Aws::S3::Resource.new(
      region: ENV['FOG_REGION'],
      credentials: credentials
    ).bucket(ENV['FOG_BUCKET'])

    presigned_url = s3_bucket.presigned_post(
      key: "#{params[:bucket_name]}/#{Rails.env}/#{SecureRandom.uuid}/#{params[:filename]}",
      success_action_status: '201',
      acl: 'public-read',
      signature_expiration: (Time.now.utc + 15.minutes)
    )

    render json: { url: presigned_url.url, fields: presigned_url.fields }, status: :ok
  end
end
