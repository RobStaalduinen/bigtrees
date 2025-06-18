class TrackersController < ApplicationController
  layout 'admin'

  def new

  end

  def index
    authorize Estimate, :admin?

    @estimates = policy_scope(Estimate)

    if params[:scope] && params[:scope] == 'past_year'
      @estimates = @estimates.where("estimates.created_at >= ?", Date.today - 1.year)
    end

    master_tracker = GenerateMasterTracker.call(@estimates.submitted.includes(site: [ :address ]))

    respond_to do |format|
      format.xlsx {
        send_file master_tracker, filename: "MasterTracker.xlsx"
      }
    end
  end
end
