class DocumentsController < ApplicationController
  layout 'admin_material'

  before_action :set_arborist

  def new
  
  end

  def create
    authorize! :read, @arborist

    document = @arborist.documents.new(document_params)

    unless document.save
      flash.now[:error] = 'Error saving document. Please ensure the doc is a proper PDF or image file.'
    end

    redirect_to new_arborist_document_path(@arborist)
  end

  def destroy
    authorize! :read, @arborist

    @document = Document.find(params[:id])
    @document.destroy

    redirect_to new_arborist_document_path(@arborist)
  end

  private
    def document_params
      params.require(:document).permit(:name, :file)
    end

    def set_arborist
      @arborist = Arborist.find(params[:arborist_id])
    end

  
end
