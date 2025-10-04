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
    @estimate_link = "https://admin.bigtreeservices.ca/admin/estimates/#{estimate.id}"

    if @organization.nylas_account && @organization.feature_enabled?(:job_email_alternate_send) && send_nylas_mail?
      content = render_to_string(template: "job_mailer/job_alert", formats: [:html])

      send_direct_mail(
        to: @organization.email, 
        subject: subject, 
        body: content, 
        organization: @organization,
        bcc: ['rob.staalduinen@gmail.com']
      )
    else
      mail(to: @organization.email, bcc: 'rob.staalduinen@gmail.com', subject: subject)
    end
  end
end