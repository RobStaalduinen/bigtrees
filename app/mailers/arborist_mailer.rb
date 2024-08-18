class ArboristMailer < ApplicationMailer

  def existing_arborist_mailout(arborist, membership)
    @arborist = arborist
    @membership = membership

    author = @membership.organization.name
    subject = "Big Tree Services - New company"

    mail(to: @arborist.email, from: @membership.organization.quote_author, subject: subject, bcc: ['rob.staalduinen@gmail.com'])
  end

  def new_arborist_mailout(arborist, membership, initial_password)
    @arborist = arborist
    @membership = membership
    @initial_password = initial_password

    author = @membership.organization.name
    subject = "Big Tree Services - Welcome"

    mail(to: @arborist.email, from: @membership.organization.quote_author, subject: subject, bcc: ['rob.staalduinen@gmail.com'])
  end

end
