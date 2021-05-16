class DocumentsController < ApplicationController
  before_action :set_arborist

  def index
    authorize Document, :index?

    render json: @arborist.documents
  end

  def new

  end

  def create
    authorize Document, :create?

    document = @arborist.documents.create(document_params)
    render json: document
  end

  def update
    authorize Document, :update?

    document = @arborist.documents.find(params[:id])
    document.update(document_params)
    render json: document
  end

  def destroy
    authorize Document, :destroy?

    @document = @arborist.documents.find(params[:id])
    @document.destroy

    render json: {}
  end

  private

  def document_params
    params.require(:document).permit(:name, :file, :url, :expires_at)
  end

  def set_arborist
    @arborist = policy_scope(Arborist).find(params[:arborist_id])
  end


end
