class JobMailer < ApplicationMailer
  #default from: 'Big Tree Care <no-reply@bigtreeservices.ca>'
  default from: 'Big Tree Care <no-reply@bigtreeservices.ca>'

  def job_alert(job, estimate)
    return unless estimate.organization.feature_enabled?(:job_notifications)

    if job.completed?
      subject = "Job at #{estimate.site.full_address} Completed by #{job.arborist.name}"
    else
      subject = "Job at #{estimate.site.full_address} Started by #{job.arborist.name}"
    end

    @job = job
    @estimate = estimate
    @organization = estimate.organization
    @estimate_link = Rails.application.routes.url_helpers.estimate_url(estimate, host: 'admin.bigtreeservices.ca')

    mail(to: @organization.email, bcc: 'rob.staalduinen@gmail.com', subject: subject)
  end
end