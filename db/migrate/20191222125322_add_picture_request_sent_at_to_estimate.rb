class AddPictureRequestSentAtToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :estimates, :picture_request_sent_at, :date
  end
end
