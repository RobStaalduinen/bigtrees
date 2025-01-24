class TagsController < ApplicationController
  
  def index
    authorize Tag, :index?

    organization = Organization.find(params[:organization_id])

    render json: organization.tags
  end

  def create
    authorize Tag, :create?

    tag = Tag.new(tag_params)
    tag.organization = Organization.find(params[:organization_id])
    tag.save

    render json: tag
  end

  def update
    authorize Tag, :update?

    organization = Organization.find(params[:organization_id])
    tag = organization.tags.find(params[:id])
    tag.update(tag_params)

    render json: tag
  end

  def destroy
    authorize Tag, :destroy?
    
    organization = Organization.find(params[:organization_id])
    tag = organization.tags.find(params[:id])
    tag.destroy

    render json: {}
  end

  private

  def tag_params
    params.require(:tag).permit(:label, :colour)
  end
end