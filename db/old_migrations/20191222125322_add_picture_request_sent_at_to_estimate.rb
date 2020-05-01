class AddPictureRequestSentAtToEstimate < ActiveRecord::Migration
  def change
    add_column :estimates, :picture_request_sent_at, :date
  end
end
