class TreesController < ApplicationController

  def create
    @estimate = Estimate.find(params[:estimate_id])
    @tree = @estimate.trees.create(tree_params)
    
    work_type = Tree.work_type_for_name(params[:tree][:work_type_string])

    @tree.update(work_type: work_type)

    render json: { status: :ok, tree_id: @tree.id }
  end

  private

    def tree_params
      params.require(:tree).permit(
        :stump_removal, :description, :in_backyard
      )
    end
end
