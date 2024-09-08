class TreesController < ApplicationController
  def create
    work_type = Tree.work_type_for_name(params[:tree][:work_type_string])
    @tree = estimate.trees.create(tree_params.merge(work_type: work_type))

    render json: { status: :ok, tree_id: @tree.id, tree: TreeSerializer.new(@tree).serializable_hash }
  end

  def admin_create
    tree = estimate.trees.create(tree_params)

    render json: tree
  end

  def bulk_create
    params[:trees].each do |tree|
      # image_attributes = (tree[:tree_image_attributes] || []).map do |image|
      #   image.merge(estimate_id: estimate.id)
      # end
      new_tree = Tree.create(
        estimate: estimate,
        description: tree[:description],
        work_type: 'other'
      )

      tree[:tree_images_attributes]&.each do |image|
        TreeImage.create(
          tree: new_tree,
          estimate: estimate,
          image_url: image[:image_url]
        )
      end
    end

    render json: { status: :ok }
  end

  private

    def estimate
      @estimate ||= Estimate.find(params[:estimate_id])
    end

    def tree_params
      params.require(:tree).permit(
        :work_type, :stump_removal, :description, :in_backyard,
        tree_image_attributes: [ :image_url ]
      )
    end
end
