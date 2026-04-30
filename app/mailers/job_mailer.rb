class JobMailer < ApplicationMailer
  #default from: 'Big Tree Care <no-reply@bigtreeservices.ca>'
  default from: 'Big Tree Care <no-reply@bigtreeservices.ca>'

  def job_alert(job, estimate)
    return unless estimate.organization.feature_enabled?(:job_notifications)

    subject_prefix = "#{estimate.customer_detail.name} - #{estimate.site&.address&.city}"

    subject_suffix = if job.completed? && estimate.work_complete?
      "Complete"
    elsif job.completed? && !estimate.work_complete?
      "Paused"
    else
      "Started"
    end

    subject = "#{subject_prefix} - #{subject_suffix}"

    @job = job
    @estimate = estimate
    @organization = estimate.organization
    @estimate_link = "https://admin.bigtreeservices.ca/admin/estimates/#{estimate.id}"

    if @organization.nylas_account && @organization.feature_enabled?(:use_connected_email) && send_nylas_mail?
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