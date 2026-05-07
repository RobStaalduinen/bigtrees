module Uploads
  class MultipartController < ApplicationController
    def create
      service = S3::MultipartUpload.new(
        bucket_name:  params.require(:bucket_name),
        filename:     params.require(:filename),
        content_type: params.require(:content_type)
      )
      result = service.initiate
      render json: { upload_id: result.upload_id, key: result.key }, status: :ok
    rescue Aws::S3::Errors::ServiceError => e
      Rails.logger.error("S3 multipart init failed: #{e.message}")
      render json: { error: 'Upload service unavailable' }, status: :bad_gateway
    end

    def parts
      part_numbers = Array(params.require(:part_numbers)).map(&:to_i)
      service = S3::MultipartUpload.new(upload_id: params[:upload_id], key: params.require(:key))
      parts = service.presign_parts(part_numbers)
      render json: { parts: parts }, status: :ok
    rescue ArgumentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue Aws::S3::Errors::ServiceError => e
      Rails.logger.error("S3 multipart parts failed: #{e.message}")
      render json: { error: 'Upload service unavailable' }, status: :bad_gateway
    end

    def complete
      raw_parts = params.require(:parts).map do |p|
        { part_number: p[:part_number].to_i, etag: p[:etag] }
      end
      service = S3::MultipartUpload.new(upload_id: params[:upload_id], key: params.require(:key))
      url = service.complete(raw_parts)
      render json: { url: url }, status: :ok
    rescue Aws::S3::Errors::EntityTooSmall
      render json: { error: 'A part was below the 5 MB minimum; please retry.' }, status: :unprocessable_entity
    rescue Aws::S3::Errors::ServiceError => e
      Rails.logger.error("S3 multipart complete failed: #{e.message}")
      render json: { error: 'Upload service unavailable' }, status: :bad_gateway
    end

    def destroy
      service = S3::MultipartUpload.new(upload_id: params[:upload_id], key: params.require(:key))
      service.abort
      head :no_content
    rescue Aws::S3::Errors::ServiceError => e
      Rails.logger.error("S3 multipart abort failed: #{e.message}")
      render json: { error: 'Upload service unavailable' }, status: :bad_gateway
    end
  end
end
