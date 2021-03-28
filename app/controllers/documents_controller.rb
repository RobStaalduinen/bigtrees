class DocumentsController < ApplicationController
  before_action :set_arborist

  def index
    authorize! :read, @arborist

    render json: @arborist.documents
  end

  def new

  end

  def create
    document = @arborist.documents.create(document_params)
    render json: document
  end

  def update
    document = @arborist.documents.find(params[:id])
    document.update(document_params)
    render json: document
  end

  def destroy
    @document = @arborist.documents.find(params[:id])
    @document.destroy

    render json: {}
  end

  private

  def document_params
    params.require(:document).permit(:name, :file, :url, :expires_at)
  end

  def set_arborist
    @arborist = Arborist.find(params[:arborist_id])
  end


end
