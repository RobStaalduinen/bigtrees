class TreeImagesController < ApplicationController

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
      key: "tree_images/#{Rails.env}/#{SecureRandom.uuid}/#{params[:filename]}",
      success_action_status: '201',
      acl: 'public-read',
      signature_expiration: (Time.now.utc + 15.minutes)
    )

    render json: { url: presigned_url.url, fields: presigned_url.fields }, status: :ok
  end

  def create
    params[:images].each do |image|
      TreeImage.create(
        tree: tree,
        asset: image
      )
    end

    render json: { status: :ok }
  end

  def update
    tree_image = TreeImage.find(params[:id])

    tree_image.update(tree_image_params)

    render json: estimate
  end

  # Temporary, while supporting two different creation mechanisms
  def create_from_urls
    if params[:images].present? && params[:images].any?
      params[:images].each do |image|
        TreeImage.create(
          tree: tree,
          image_url: image
        )
      end
    end

    render json: estimate
  end

  private

  def tree
    @tree ||= if params[:tree_id].present?
                Tree.find(params[:tree_id])
              else
                Tree.create(estimate_id: params[:estimate_id], work_type: 4)
              end
  end

  def estimate
    @estimate ||= Estimate.find(params[:estimate_id])
  end

  def tree_image_params
    params.permit(:image_url, :edited_image_url)
  end
end
