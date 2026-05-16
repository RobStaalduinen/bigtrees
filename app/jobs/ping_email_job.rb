class PingEmailJob < ApplicationJob
  queue_as :default

  def perform(organization_id)
    organization = Organization.find(organization_id)

    unless organization.nylas_account
      Rails.logger.warn("[PingEmailJob] org=#{organization.id} has no nylas_account; skipping")
      return
    end

    email_definition = Nylas::EmailDefinition.new(
      to: 'rob.staalduinen@gmail.com',
      subject: "[Ping] Solid Queue test from #{organization.name} - #{Time.current.iso8601}",
      outgoing_name: organization.name,
      body: "<p>Ping from PingEmailJob via Solid Queue.</p>" \
            "<p>Organization: #{organization.name} (id=#{organization.id})</p>" \
            "<p>Enqueued and executed at #{Time.current.iso8601}.</p>",
      bcc: []
    )

    Nylas::Wrapper.new.send_email(organization.nylas_account, email_definition, nil, use_test_grant: true)
  end
end
