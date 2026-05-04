class ArboristMailer < ApplicationMailer

  def existing_arborist_mailout(arborist, membership)
    @arborist = arborist
    @membership = membership
    @organization = membership.organization
    return unless @organization.nylas_account

    author = @membership.organization.name
    subject = "Big Tree Services - New company"
    content = render_to_string(template: "arborist_mailer/existing_arborist_mailout", formats: [:html])

    send_direct_mail(
      to: @arborist.email,
      outgoing_name: author,
      subject: subject,
      body: content,
      organization: @organization,
    )
  end

  def new_arborist_mailout(arborist, membership, initial_password)
    @arborist = arborist
    @membership = membership
    @organization = membership.organization
    @initial_password = initial_password
    return unless @organization.nylas_account

    author = @membership.organization.name
    subject = "Big Tree Services - Welcome"
    content = render_to_string(template: "arborist_mailer/new_arborist_mailout", formats: [:html])

    send_direct_mail(
      to: @arborist.email,
      outgoing_name: author,
      subject: subject,
      body: content,
      organization: @organization
    )
  end

end
