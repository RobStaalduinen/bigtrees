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

  def admin_update
    tree = estimate.trees.find(params[:id])
    tree.update(tree_params)

    render json: tree
  end

  def bulk_create
    # Images are no longer embedded here. The client uploads them via the
    # durable background queue and associates each one to its tree using the
    # returned tree_ids (in input order) + the idempotent associate endpoint.
    trees = params[:trees].map do |tree|
      Tree.create(
        estimate: estimate,
        description: tree[:description],
        work_type: 'other'
      )
    end

    render json: { status: :ok, tree_ids: trees.map(&:id) }
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
