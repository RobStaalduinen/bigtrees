module Estimates
  class Duplicate
    def self.call(estimate_id)
      new(estimate_id).call
    end

    def initialize(estimate_id)
      @original_estimate = Estimate.find(estimate_id)
    end

    def call
      new_estimate = nil

      ActiveRecord::Base.transaction do
        new_estimate = @original_estimate.dup
        new_estimate.status = :needs_costs
        new_estimate.submission_completed = true
        new_estimate.quote_sent_date = nil
        new_estimate.quote_accepted_date = nil
        new_estimate.work_start_date = nil
        new_estimate.work_end_date = nil
        new_estimate.work_completion_date = nil
        new_estimate.cancelled_at = nil
        new_estimate.approved = false
        new_estimate.created_at = Time.current
        new_estimate.updated_at = Time.current
        new_estimate.save!

        duplicate_associations(new_estimate)

        new_estimate.save! # Save again to update status
      end

      new_estimate
    end

    private

    def duplicate_associations(new_estimate)
      # Duplicate Trees and Tree Images
      @original_estimate.trees.each do |tree|
        new_tree = tree.dup
        new_tree.estimate = new_estimate
        new_tree.save!

        tree.tree_images.each do |image|
          new_image = image.dup
          new_image.tree = new_tree
          new_image.estimate = new_estimate
          new_image.save!
        end
      end

      # Duplicate Costs
      @original_estimate.costs.each do |cost|
        new_cost = cost.dup
        new_cost.estimate = new_estimate
        new_cost.save!
      end

      # Duplicate Notes
      @original_estimate.notes.each do |note|
        new_note = note.dup
        new_note.estimate = new_estimate
        new_note.save!
      end

      # Duplicate Equipment Assignments
      @original_estimate.equipment_assignments.each do |assignment|
        new_assignment = assignment.dup
        new_assignment.estimate = new_estimate
        new_assignment.save!
      end

      # Duplicate Taggings
      @original_estimate.taggings.each do |tagging|
        new_tagging = tagging.dup
        new_tagging.estimate = new_estimate
        new_tagging.save!
      end

      # Duplicate Site
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

      # Duplicate Customer Detail
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
