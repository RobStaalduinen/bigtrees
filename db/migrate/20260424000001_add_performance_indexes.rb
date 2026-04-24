class AddPerformanceIndexes < ActiveRecord::Migration[6.0]
  def change
    # estimates.organization_id — every multi-tenant query filters by this; no index is a significant gap
    add_index :estimates, :organization_id, unless: index_exists?(:estimates, :organization_id)
    # estimates.state — heavily used in scopes (in_progress, done, cancelled)
    add_index :estimates, :state, unless: index_exists?(:estimates, :state)
    # composite: the most common query pattern is filtering by both org and state
    add_index :estimates, %i[organization_id state], name: "index_estimates_on_organization_id_and_state",
              unless: index_exists?(:estimates, %i[organization_id state])

    # costs.estimate_id — no index on this has_many FK; costs are sum-aggregated per estimate constantly
    add_index :costs, :estimate_id, unless: index_exists?(:costs, :estimate_id)

    # receipts — org-scoped and arborist-scoped queries; approval queue filters by state+org
    add_index :receipts, :organization_id, unless: index_exists?(:receipts, :organization_id)
    add_index :receipts, :arborist_id, unless: index_exists?(:receipts, :arborist_id)
    add_index :receipts, %i[organization_id state], name: "index_receipts_on_organization_id_and_state",
              unless: index_exists?(:receipts, %i[organization_id state])

    # work_records — payroll queries always scope by org; payout grouping needs payout_id
    add_index :work_records, :organization_id, unless: index_exists?(:work_records, :organization_id)
    add_index :work_records, :payout_id, unless: index_exists?(:work_records, :payout_id)
    add_index :work_records, %i[organization_id date], name: "index_work_records_on_organization_id_and_date",
              unless: index_exists?(:work_records, %i[organization_id date])

    # equipment_requests — org-scoped, filtered by state and assignee
    add_index :equipment_requests, :organization_id, unless: index_exists?(:equipment_requests, :organization_id)
    add_index :equipment_requests, :arborist_id, unless: index_exists?(:equipment_requests, :arborist_id)
    add_index :equipment_requests, :mechanic_id, unless: index_exists?(:equipment_requests, :mechanic_id)
    add_index :equipment_requests, :state, unless: index_exists?(:equipment_requests, :state)

    # equipment_assignments — both sides of the join need indexes
    add_index :equipment_assignments, :estimate_id, unless: index_exists?(:equipment_assignments, :estimate_id)
    add_index :equipment_assignments, :vehicle_id, unless: index_exists?(:equipment_assignments, :vehicle_id)

    # tree_images — loaded per tree and per estimate
    add_index :tree_images, :tree_id, unless: index_exists?(:tree_images, :tree_id)
    add_index :tree_images, :estimate_id, unless: index_exists?(:tree_images, :estimate_id)

    # images — polymorphic association needs both columns indexed together
    add_index :images, %i[imageable_type imageable_id], name: "index_images_on_imageable",
              unless: index_exists?(:images, %i[imageable_type imageable_id])

    # jobs.arborist_id — lead arborist lookups on the jobs table
    add_index :jobs, :arborist_id, unless: index_exists?(:jobs, :arborist_id)

    # vehicles.organization_id — org vehicle list and availability checks
    add_index :vehicles, :organization_id, unless: index_exists?(:vehicles, :organization_id)

    # expirations.vehicle_id — maintenance/expiry lookups per vehicle
    add_index :expirations, :vehicle_id, unless: index_exists?(:expirations, :vehicle_id)
  end
end
