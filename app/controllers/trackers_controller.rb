class TrackersController < ApplicationController
  layout 'admin'

  def new

  end

  def index
    authorize Estimate, :admin?

    @estimates = policy_scope(Estimate)

    master_tracker = GenerateMasterTracker.call(@estimates.submitted.includes(site: [ :address ]))

    respond_to do |format|
      format.xlsx {
        send_file master_tracker, filename: "MasterTracker.xlsx"
      }
    end
  end
end
