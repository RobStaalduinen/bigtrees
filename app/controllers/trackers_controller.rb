class TrackersController < ApplicationController

  def new

  end

  def index
    master_tracker = GenerateMasterTracker.call(Estimate.complete)

    respond_to do |format| 
      format.xlsx {
        send_file master_tracker, filename: "MasterTracker.xlsx"
      }
    end
  end
end
