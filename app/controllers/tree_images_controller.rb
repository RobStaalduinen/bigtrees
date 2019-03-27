class TreeImagesController < ApplicationController

  def create

    [:imageOne, :imageTwo, :imageThree].each do |image|
      next if params[image].blank? || params[image] == 'undefined'
      TreeImage.create(
        tree_id: params[:tree_id],
        asset: params[image]
      )
    end
    
    render json: { status: :ok }
  end
  
end
