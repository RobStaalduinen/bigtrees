# frozen_string_literal: true

class JobsController < ApplicationController
  
  def create
    job = estimate.job || Job.new(estimate: estimate)

    job.arborist = current_user

    job.update(job_params)

    if params[:job][:assigned_arborists].present?
      params[:job][:assigned_arborists].each do |arborist_id|
        JobAssignment.create(job: job, arborist_id: arborist_id)
      end
    end

    estimate.save # Update status
    
    JobMailer.job_alert(job, estimate).deliver_now if estimate.organization.feature_enabled?(:job_notifications) if !job.skipped?

    render json: estimate
  end

  private

  def estimate
    @estimate ||= Estimate.find(params[:estimate_id])
  end

  def job_params
    params.require(:job).permit(:started_at, :completed_at, :skipped, job_survey_responses: {})
  end
end