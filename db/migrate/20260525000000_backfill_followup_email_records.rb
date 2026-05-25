class BackfillFollowupEmailRecords < ActiveRecord::Migration[6.0]
  def up
    Estimate.where.not(followup_sent_at: nil).find_each do |estimate|
      next if EmailRecord.exists?(estimate_id: estimate.id, template_key: 'no_response')

      EmailRecord.create!(
        estimate_id: estimate.id,
        arborist_id: estimate.arborist_id,
        organization_id: estimate.organization_id,
        template_key: 'no_response',
        sent_at: estimate.followup_sent_at
      )
    end

    Estimate.where.not(picture_request_sent_at: nil).find_each do |estimate|
      next if EmailRecord.exists?(estimate_id: estimate.id, template_key: 'image_request')

      EmailRecord.create!(
        estimate_id: estimate.id,
        arborist_id: estimate.arborist_id,
        organization_id: estimate.organization_id,
        template_key: 'image_request',
        sent_at: estimate.picture_request_sent_at.to_time
      )
    end
  end

  def down
    # No-op: we cannot distinguish backfilled records from real sends.
  end
end
