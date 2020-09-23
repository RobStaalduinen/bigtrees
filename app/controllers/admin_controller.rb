class AdminController < ApplicationController
	def index
		render 'index', layout: 'admin_vue'
	end
end
