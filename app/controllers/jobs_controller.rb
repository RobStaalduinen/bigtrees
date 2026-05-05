# frozen_string_literal: true

class JobsController < ApplicationController

  def create
    job = estimate.jobs.build

    job.arborist = current_user

    job.update(job_params)

    if params[:job][:assigned_arborists].present?
      params[:job][:assigned_arborists].each do |arborist_id|
        JobAssignment.create(job: job, arborist_id: arborist_id)
      end
    end

    estimate.save # Update status

    JobMailer.job_alert(job, estimate).deliver_now if estimate.organization.notification_enabled?(:job)

    render json: estimate
  end

  def update
    job = estimate.jobs.find(params[:id])

    unless can_edit_job?(job)
      render json: { error: 'Unauthorized' }, status: :forbidden and return
    end

    newly_completed = job.completed_at.nil? && params[:job][:completed_at].present?

    job.completed_by = current_user if newly_completed
    job.update(job_params)

    if params[:job][:assigned_arborists].present?
      job.job_assignments.destroy_all
      params[:job][:assigned_arborists].each do |arborist_id|
        JobAssignment.create(job: job, arborist_id: arborist_id)
      end
    end

    if params[:work_complete].present?
      estimate.work_complete = true
    end

    estimate.save

    if newly_completed && estimate.organization.notification_enabled?(:job)
      JobMailer.job_alert(job, estimate).deliver_now
    end

    render json: estimate
  end

  private

  def estimate
    @estimate ||= Estimate.find(params[:estimate_id])
  end

  def can_edit_job?(job)
    editable_statuses = %w[work_started work_paused work_completed]
    is_admin = %w[admin super_admin].include?(current_user.role)
    is_admin || editable_statuses.include?(estimate.status)
  end

  def job_params
    params.require(:job).permit(:started_at, :completed_at, :completion_notes, :followup_year, job_survey_responses: {}, completion_survey_responses: {})
  end
end
