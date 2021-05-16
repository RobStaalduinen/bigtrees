class TreesController < ApplicationController

  def create
    authorize Estimate, :update?

    @tree = estimate.trees.create(tree_params)

    work_type = Tree.work_type_for_name(params[:tree][:work_type_string])

    @tree.update(work_type: work_type)

    render json: { status: :ok, tree_id: @tree.id }
  end

  def bulk_create
    authorize Estimate, :update?

    params[:trees].each do |tree|
      estimate.trees.create(tree.permit(:description, tree_images_attributes: [:image_url]).merge(work_type: 'other'))
    end

    render json: { status: :ok }
  end

  private

    def estimate
      @estimate ||= policy_scope(Estimate).find(params[:estimate_id])
    end

    def tree_params
      params.require(:tree).permit(
        :stump_removal, :description, :in_backyard,
        tree_image_attributes: [ :image_url ]
      )
    end
end
