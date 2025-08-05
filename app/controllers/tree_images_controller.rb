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

  def show
    tree_image = TreeImage.find(params[:id])

    if params[:edited] == 'true' && tree_image.edited_image_url.present?
      image_url = tree_image.edited_image_url
    else
      image_url = tree_image.image_url
    end
    parsed_url = URI.parse(image_url)
    key = URI.decode_www_form_component(parsed_url.path.sub(/^\//, ''))

    obj = Aws::S3::Client.new(
      region: ENV['FOG_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    ).get_object(bucket: ENV['FOG_BUCKET'], key: key)
    send_data obj.body.read, type: obj.content_type, disposition: 'inline'
  end

  def create
    params[:images].each do |image|
      TreeImage.create(
        tree: tree,
        asset: image,
        estimate: tree.estimate
      )
    end

    render json: { status: :ok }
  end

  def update
    tree_image = TreeImage.find(params[:id])

    tree_image.update(tree_image_params)

    render json: estimate
  end

  def destroy
    tree_image = TreeImage.find(params[:id])
    tree_image.destroy

    render json: estimate
  end

  # Temporary, while supporting two different creation mechanisms
  def create_from_urls
    authorize Estimate, :update?

    if params[:images].present? && params[:images].any?
      params[:images].each do |image|
        TreeImage.create(
          tree: tree,
          estimate_id: params[:estimate_id],
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
              elsif params[:new_tree] == true
                Tree.create(estimate_id: params[:estimate_id], work_type: 4)
              else
                nil
              end
  end

  def estimate
    @estimate ||= policy_scope(Estimate).find(params[:estimate_id])
  end

  def tree_image_params
  params.permit(:tree_id, :image_url, :edited_image_url)
  end
end
