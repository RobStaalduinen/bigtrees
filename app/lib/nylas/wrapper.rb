# frozen_string_literal: true

module Nylas
  class Wrapper
    def initialize
      @config = {
        client_id: ENV['NYLAS_CLIENT_ID'],
        callback_uri: 'https://admin.bigtreeservices.ca/nylas_accounts/receive_grant',
        api_key: ENV['NYLAS_API_KEY'],
        api_uri: ENV['NYLAS_API_URI']
      }

      @client = Nylas::Client.new(
        api_key: @config[:api_key],
        api_uri: @config[:api_uri]
      )
    end

    def validate_grant(nylas_account)
      grant = @client.grants.find(grant_id: nylas_account.grant_id)

      if grant.nil? || grant.first[:grant_status] != 'valid'
        nylas_account.update(status: 'unsynced')
        raise "Email connection must be resynced"
      end
    end

    def send_email(nylas_account, email_definition, attachment = nil)
      validate_grant(nylas_account)

      grant_id = nylas_account.grant_id

      if Rails.env.development?
        to_list = [ { email: 'rob.staalduinen@gmail.com'} ]
        puts "Sending email in development mode to: #{to_list}"
      else
        to_list = email_definition.receipient_list
      end


      attachments = []

      if attachment
        attachments << attachment.definition_entry
      end

      request_body = {
        to: to_list,
        from: [{
          name: nylas_account.organization.email_author,
          email: nylas_account.outgoing_email_address
        }],
        bcc: email_definition.bcc_list,
        reply_to: [{ name: nylas_account.organization.email_author, email: nylas_account.outgoing_email_address }],
        subject: email_definition.subject,
        body: email_definition.body,
        attachments: attachments
      }

      @client.messages.send(
        identifier: grant_id,
        request_body: request_body
      )
    end

    def remove_grant(nylas_account)
      @client.grants.destroy(grant_id: nylas_account.grant_id)
    end

    def auth_url
      @client.auth.url_for_oauth2({
        client_id: @config[:client_id],
        redirect_uri: @config[:callback_uri]
      })
    end

    def exchange_code_for_token(code)
      @client.auth.exchange_code_for_token(
        code: code,
        client_id: @config[:client_id],
        redirect_uri: @config[:callback_uri]
      )
    end
  end
end