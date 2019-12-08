class TrackersController < ApplicationController
  layout 'admin'
  
  def new

  end

  def index
    master_tracker = GenerateMasterTracker.call(Estimate.submitted)

    respond_to do |format| 
      format.xlsx {
        send_file master_tracker, filename: "MasterTracker.xlsx"
      }
    end
  end
end
