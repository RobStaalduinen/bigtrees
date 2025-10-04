class ArboristMailer < ApplicationMailer

  def existing_arborist_mailout(arborist, membership)
    @arborist = arborist
    @membership = membership
    @organization = membership.organization

    author = @membership.organization.name
    subject = "Big Tree Services - New company"

    if @organization.nylas_account && send_nylas_mail?
      content = render_to_string(template: "arborist_mailer/existing_arborist_mailout", formats: [:html])

      send_direct_mail(
        to: @arborist.email, 
        outgoing_name: author,
        subject: subject, 
        body: content, 
        organization: @organization,
      )
    else
      mail(to: @arborist.email, from: @organization.quote_author, subject: subject, bcc: ['rob.staalduinen@gmail.com'])
    end
    
  end

  def new_arborist_mailout(arborist, membership, initial_password)
    @arborist = arborist
    @membership = membership
    @organization = membership.organization
    @initial_password = initial_password

    author = @membership.organization.name
    subject = "Big Tree Services - Welcome"

    if @organization.nylas_account && send_nylas_mail?
      content = render_to_string(template: "arborist_mailer/new_arborist_mailout", formats: [:html])

      send_direct_mail(
        to: @arborist.email, 
        outgoing_name: author,
        subject: subject, 
        body: content, 
        organization: @organization
      )
    else
      mail(to: @arborist.email, from: @membership.organization.quote_author, subject: subject, bcc: ['rob.staalduinen@gmail.com'])
    end
  end

end
