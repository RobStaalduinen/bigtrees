class HoursController < ApplicationController

  def index
    
    render 'index', layout: 'admin_vue'
  end

end
