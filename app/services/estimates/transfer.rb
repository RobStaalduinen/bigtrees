module Estimates
  # Moves a quote from one organization to another by deep-copying its generic
  # data (customer, addresses, site, images, notes, costs) into the target org
  # as a fresh in-progress quote, then marking the source as `transferred`.
  #
  # Org-specific data is intentionally NOT copied: equipment assignments and
  # taggings reference source-org Vehicles/Tags, and jobs/invoice/email_records
  # are org history. The copied arborist is remapped to the target org's
  # default arborist (the arborist_id column is required).
  #
  # Mirrors Estimates::Duplicate; keep the two in sync.
  class Transfer
    # Raised for guard failures the UI should surface as a 422 (rather than a
    # generic 500), e.g. the source org isn't allowed to transfer or the target
    # org has no arborist to receive the quote.
    class TransferError < StandardError; end

    def self.call(estimate_id, target_organization_id)
      new(estimate_id, target_organization_id).call
    end

    def initialize(estimate_id, target_organization_id)
      @original_estimate = Estimate.find(estimate_id)
      @target_organization = Organization.find(target_organization_id)
    end

    def call
      validate!

      new_estimate = nil

      ActiveRecord::Base.transaction do
        new_estimate = @original_estimate.dup
        new_estimate.status = :needs_costs
        new_estimate.state = :in_progress
        new_estimate.state_reason = nil
        new_estimate.submission_completed = true
        new_estimate.quote_sent_date = nil
        new_estimate.quote_accepted_date = nil
        new_estimate.work_start_date = nil
        new_estimate.work_end_date = nil
        new_estimate.work_completion_date = nil
        new_estimate.cancelled_at = nil
        new_estimate.approved = false
        new_estimate.work_complete = false
        new_estimate.is_unknown = false
        new_estimate.picture_request_sent_at = nil
        new_estimate.followup_sent_at = nil
        new_estimate.created_at = Time.current
        new_estimate.updated_at = Time.current

        # The cross-org bits: repoint to the target org and its default arborist,
        # and record where this copy came from.
        new_estimate.organization = @target_organization
        new_estimate.arborist = @target_organization.default_arborist
        new_estimate.transferred_from = @original_estimate
        new_estimate.save!

        transfer_associations(new_estimate)

        new_estimate.save! # Save again to update status

        @original_estimate.update!(state: 'transferred')
      end

      new_estimate
    end

    private

    def validate!
      unless @original_estimate.organization&.can_transfer
        raise TransferError, 'This organization is not permitted to transfer quotes.'
      end

      if @original_estimate.transferred?
        raise TransferError, 'This quote has already been transferred.'
      end

      if @target_organization.default_arborist.nil?
        raise TransferError, 'The destination organization has no arborist to receive the quote.'
      end
    end

    def transfer_associations(new_estimate)
      # Trees (map original -> copy so images can be reattached to the right one)
      tree_map = {}
      @original_estimate.trees.each do |tree|
        new_tree = tree.dup
        new_tree.estimate = new_estimate
        new_tree.save!
        tree_map[tree.id] = new_tree
      end

      # Tree images (image_url is a shared S3 reference, copied as-is). Iterate
      # the estimate's images directly so uncategorized images (tree_id nil) are
      # copied too, not just those attached to a tree.
      @original_estimate.tree_images.each do |image|
        new_image = image.dup
        new_image.estimate = new_estimate
        new_image.tree = image.tree_id ? tree_map[image.tree_id] : nil
        # client_upload_id has a unique index; it identifies the original
        # client-side upload and must not be carried onto a copy.
        new_image.client_upload_id = nil
        new_image.save!
      end

      # Costs
      @original_estimate.costs.each do |cost|
        new_cost = cost.dup
        new_cost.estimate = new_estimate
        new_cost.save!
      end

      # Notes. author_name is snapshotted on the copy (carried over by dup), so
      # the original author is preserved for the record even though the source
      # arborist isn't in the target org; clear the cross-org arborist_id FK
      # (Note#set_default_author repoints it, but the displayed name stays).
      # Copy the note's attached image (SingleImageable) as a shared S3 ref too.
      @original_estimate.notes.each do |note|
        new_note = note.dup
        new_note.estimate = new_estimate
        new_note.arborist_id = nil
        new_note.save!

        if note.image
          new_note_image = note.image.dup
          new_note_image.imageable = new_note
          new_note_image.save!
        end
      end

      # Equipment assignments and taggings are deliberately NOT copied: they
      # point at source-org Vehicles/Tags that don't exist in the target org.

      # Site
      if @original_estimate.site
        new_site = @original_estimate.site.dup
        new_site.estimate = new_estimate
        new_site.save!

        if @original_estimate.site.address
          new_address = @original_estimate.site.address.dup
          new_address.addressable = new_site
          new_address.save!
        end
      end

      # Customer Detail
      if @original_estimate.customer_detail
        new_customer_detail = @original_estimate.customer_detail.dup
        new_customer_detail.estimate = new_estimate
        new_customer_detail.save!

        if @original_estimate.customer_detail.address
          new_address = @original_estimate.customer_detail.address.dup
          new_address.addressable = new_customer_detail
          new_address.save!
        end
      end
    end
  end
end
