class AdminBaseController < ApplicationController
  layout 'admin'
  before_action :signed_in_user
  
end
