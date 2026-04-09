# frozen_string_literal: true

require 'net/http'
require 'securerandom'

module Nylas
  class Wrapper
    def initialize
      @config = {
        client_id: ENV['NYLAS_CLIENT_ID'],
        callback_uri: ENV['NYLAS_CALLBACK_URI'],
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
      else
        nylas_account.update(status: 'active')
      end
    rescue Nylas::NylasApiError => e
      nylas_account.update(status: 'unsynced')

    end

    def send_email(nylas_account, email_definition, attachment = nil)
      validate_grant(nylas_account)

      if Rails.env.development?
        to_list = [ { email: 'rob.staalduinen@gmail.com'} ]
        puts "Sending email in development mode to: #{to_list}"
      else
        to_list = email_definition.receipient_list
      end

      author = email_definition.outgoing_name.present? ? email_definition.outgoing_name : nylas_account.organization.email_author

      if attachment
        send_email_multipart(nylas_account.grant_id, to_list, author, nylas_account.outgoing_email_address, email_definition, attachment)
      else
        request_body = {
          to: to_list,
          from: [{ name: author, email: nylas_account.outgoing_email_address }],
          bcc: email_definition.bcc_list,
          reply_to: [{ name: author, email: nylas_account.outgoing_email_address }],
          subject: email_definition.subject,
          body: email_definition.body
        }

        @client.messages.send(
          identifier: nylas_account.grant_id,
          request_body: request_body
        )
      end
    rescue StandardError => e
      raise "Failed to send email."
    end

    private

    def send_email_multipart(grant_id, to_list, author, from_email, email_definition, attachment)
      uri = URI("#{@config[:api_uri]}/v3/grants/#{grant_id}/messages/send")

      message = {
        to: to_list,
        from: [{ name: author, email: from_email }],
        bcc: email_definition.bcc_list,
        reply_to: [{ name: author, email: from_email }],
        subject: email_definition.subject,
        body: email_definition.body
      }

      boundary = SecureRandom.hex(16)
      crlf = "\r\n"

      body = String.new(encoding: 'BINARY')
      body << "--#{boundary}#{crlf}"
      body << "Content-Disposition: form-data; name=\"message\"#{crlf}"
      body << "Content-Type: application/json#{crlf}#{crlf}"
      body << "#{message.to_json}#{crlf}"
      body << "--#{boundary}#{crlf}"
      body << "Content-Disposition: form-data; name=\"file0\"; filename=\"#{attachment.name}\"#{crlf}"
      body << "Content-Type: #{attachment.type}#{crlf}#{crlf}"
      body << File.binread(attachment.file_path)
      body << "#{crlf}--#{boundary}--#{crlf}"

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{@config[:api_key]}"
      request['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
      request.body = body

      response = http.request(request)

      raise "Failed to send email." unless response.code.to_i == 200

      JSON.parse(response.body)
    end

    def remove_grant(nylas_account)
      @client.grants.destroy(grant_id: nylas_account.grant_id)
    end

    def auth_url(organization)
      @client.auth.url_for_oauth2({
        client_id: @config[:client_id],
        redirect_uri: @config[:callback_uri],
        state: organization.id
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