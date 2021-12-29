class MainController < ApplicationController

def show
  if page_is_valid?
     render template: "main/#{params[:page]}"
  else
     render file: "public/404.html", status: :not_found
  end
end

def image
  @image_path = params[:image_path]

  render layout: false
end


def health
  render json: { status: :ok }
end

private
  def page_is_valid?
    File.exist?(Pathname.new(Rails.root + "app/views/main/#{params[:page]}.html.erb"))
  end

end
