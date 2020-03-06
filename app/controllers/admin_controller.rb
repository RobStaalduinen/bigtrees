class AdminController < ApplicationController
	require 'spreadsheet'
	Spreadsheet.client_encoding = 'UTF-8'

	layout 'admin'

	before_action :signed_in_user, except: [:log_in]



private

	def estimate_params
		params.require(:estimate).permit(
			:status, :work_date, :extra_cost, :extra_cost_notes, :is_unknown
		)
	end
end
