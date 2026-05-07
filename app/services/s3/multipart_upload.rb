module S3
  class MultipartUpload
    PART_URL_TTL = 15.minutes
    MAX_PART_NUMBER = 10_000

    def initialize(bucket_name: nil, filename: nil, content_type: nil, upload_id: nil, key: nil)
      @bucket_name  = bucket_name
      @filename     = filename
      @content_type = content_type
      @upload_id    = upload_id
      @key          = key
    end

    def initiate
      @key = "#{@bucket_name}/#{Rails.env}/#{SecureRandom.uuid}/#{@filename.gsub(/[^\w\-.]/, '_')}"
      resp = client.create_multipart_upload(
        bucket: bucket,
        key:    @key,
        content_type: @content_type,
        acl:    'public-read'
      )
      OpenStruct.new(upload_id: resp.upload_id, key: @key)
    end

    def presign_parts(part_numbers)
      part_numbers.map do |n|
        raise ArgumentError, "part_number must be between 1 and #{MAX_PART_NUMBER}" unless n.between?(1, MAX_PART_NUMBER)

        url = signer.presigned_url(
          :upload_part,
          bucket:      bucket,
          key:         @key,
          upload_id:   @upload_id,
          part_number: n,
          expires_in:  PART_URL_TTL.to_i
        )
        { part_number: n, url: url }
      end
    end

    def complete(parts)
      sorted = parts.map { |p| { part_number: p[:part_number].to_i, etag: p[:etag] } }
                    .sort_by { |p| p[:part_number] }
      client.complete_multipart_upload(
        bucket:           bucket,
        key:              @key,
        upload_id:        @upload_id,
        multipart_upload: { parts: sorted }
      )
      "https://#{ENV['FOG_BUCKET']}.s3.amazonaws.com/#{@key}"
    end

    def abort
      client.abort_multipart_upload(
        bucket:    bucket,
        key:       @key,
        upload_id: @upload_id
      )
    rescue Aws::S3::Errors::NoSuchUpload
      # idempotent — already cleaned up
    end

    private

    def bucket
      ENV['FOG_BUCKET']
    end

    def credentials
      Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    end

    def client
      @client ||= Aws::S3::Client.new(region: ENV['FOG_REGION'], credentials: credentials)
    end

    def signer
      @signer ||= Aws::S3::Presigner.new(client: client)
    end
  end
end
