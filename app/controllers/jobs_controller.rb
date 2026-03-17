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

    JobMailer.job_alert(job, estimate).deliver_now if estimate.organization.feature_enabled?(:job_notifications)

    render json: estimate
  end

  def update
    job = estimate.jobs.find(params[:id])
    job.update(job_params)

    if params[:work_complete].present?
      estimate.work_complete = true
      estimate.save
    else
      estimate.save
    end

    render json: estimate
  end

  private

  def estimate
    @estimate ||= Estimate.find(params[:estimate_id])
  end

  def job_params
    params.require(:job).permit(:started_at, :completed_at, :completion_notes, :followup_year, job_survey_responses: {}, completion_survey_responses: {})
  end
end
