class TreeImagesController < ApplicationController

  def create
    puts params

    [:imageOne, :imageTwo, :imageThree].each do |image|
      next if params[image] == 'undefined'
      TreeImage.create(
        tree_id: params[:tree_id],
        asset: params[image]
      )
    end
    
    render json: { status: :ok }
  end
  
end
