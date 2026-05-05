class JobMailer < ApplicationMailer
  #default from: 'Big Tree Care <no-reply@bigtreeservices.ca>'
  default from: 'Big Tree Care <no-reply@bigtreeservices.ca>'

  def job_alert(job, estimate)
    return unless estimate.organization.notification_enabled?(:job)

    @organization = estimate.organization
    return unless @organization.nylas_account

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
    @estimate_link = "https://admin.bigtreeservices.ca/admin/estimates/#{estimate.id}"

    content = render_to_string(template: "job_mailer/job_alert", formats: [:html])

    send_direct_mail(
      to: @organization.email,
      subject: subject,
      body: content,
      organization: @organization,
      bcc: ['rob.staalduinen@gmail.com']
    )
  end
end
