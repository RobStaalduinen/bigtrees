# frozen_string_literal: true

require 'net/http'
require 'securerandom'

module Nylas
  class Wrapper
    # Pulls the Nylas message id out of a `send_email` return value.
    # The SDK's `messages.send` returns a `[Hash, request_id]` tuple, while the
    # multipart path returns the raw `{"data" => {...}}` JSON body.
    def self.extract_message_id(response)
      return nil unless response

      data = response.is_a?(Array) ? response.first : response
      data = data['data'] || data[:data] if data.is_a?(Hash) && (data['data'] || data[:data])
      return nil unless data.is_a?(Hash)

      data[:id] || data['id']
    end

    # Flattens an exception into a message worth showing. For Nylas API errors the
    # useful part is usually `provider_error` — the verbatim Google/Microsoft
    # complaint — which `message` alone leaves out.
    def self.error_detail(error)
      detail = error.message.to_s

      return detail unless error.is_a?(Nylas::NylasApiError) && error.provider_error.present?

      provider = error.provider_error
      provider = provider.to_json if provider.is_a?(Hash) || provider.is_a?(Array)

      "#{detail} (provider: #{provider})"
    end

    # Provider scopes that permit sending mail. Nylas hands back the provider's
    # own scope strings on the grant, so match on the trailing segment: Microsoft
    # returns "Mail.Send" bare or prefixed ("https://graph.microsoft.com/Mail.Send",
    # "https://outlook.office365.com/Mail.Send"), Google as a full auth URL.
    #
    # Deliberately absent: Microsoft's Mail.ReadWrite and Google's gmail.readonly.
    # Neither authorizes a send, and mistaking them for one is the exact failure
    # this check exists to catch.
    SEND_SCOPE_SEGMENTS = %w[
      gmail.send
      gmail.compose
      gmail.modify
      mail.send
      mail.send.shared
    ].freeze

    # Google's full-access scope has no meaningful trailing segment.
    FULL_ACCESS_SCOPES = ['https://mail.google.com'].freeze

    def self.send_scope?(scope)
      normalized = scope.to_s.downcase.strip.chomp('/')
      return false if normalized.empty?
      return true if FULL_ACCESS_SCOPES.include?(normalized)

      SEND_SCOPE_SEGMENTS.include?(normalized.split('/').last)
    end

    # Fails open on a grant that reports no scopes at all (IMAP grants, or a
    # response shape we do not recognise). A false "insufficient" banner on a
    # working account is worse than letting the send attempt surface the truth.
    def self.missing_send_scope?(grant)
      scopes = grant[:scope] || grant['scope']
      scopes = scopes.split(/[\s,]+/) if scopes.is_a?(String)
      scopes = Array(scopes).reject { |s| s.to_s.strip.empty? }

      return false if scopes.empty?

      scopes.none? { |scope| send_scope?(scope) }
    end

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

    # Re-checks the grant against Nylas and persists the resulting status.
    # Never raises for an unusable grant: callers that only report state (the
    # status banner) need the status to come back, not an exception.
    def refresh_status(nylas_account)
      grant = @client.grants.find(grant_id: nylas_account.grant_id)&.first

      status =
        if grant.nil? || grant[:grant_status] != 'valid'
          'unsynced'
        elsif Wrapper.missing_send_scope?(grant)
          'insufficient'
        else
          'active'
        end

      nylas_account.update(status: status)
      status
    rescue Nylas::AbstractNylasApiError => e
      Sentry.capture_exception(e)
      nylas_account.update(status: 'unsynced')
      'unsynced'
    end

    # Same check, but raises when the account cannot actually send. Use this on
    # the send path.
    def validate_grant(nylas_account)
      case refresh_status(nylas_account)
      when 'insufficient'
        raise 'Email account is missing permission to send email. Please reconnect it and allow sending.'
      when 'unsynced'
        raise 'Email connection must be resynced'
      end
    end

    def send_email(nylas_account, email_definition, attachment = nil, use_test_grant: Rails.env.development?)
      if use_test_grant
        grant_id = ENV['TEST_NYLAS_GRANT_ID']
        raise "TEST_NYLAS_GRANT_ID is not configured" if grant_id.blank?
      else
        validate_grant(nylas_account)
        grant_id = nylas_account.grant_id
      end

      if Rails.env.development?
        to_list = [ { email: 'rob.staalduinen@gmail.com'} ]
        puts "Sending email in development mode to: #{to_list}"
      else
        to_list = email_definition.receipient_list
      end

      author = email_definition.outgoing_name.present? ? email_definition.outgoing_name : nylas_account.organization.email_author

      if attachment
        send_email_multipart(grant_id, to_list, author, nylas_account.outgoing_email_address, email_definition, attachment)
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
          identifier: grant_id,
          request_body: request_body
        )
      end
    rescue StandardError => e
      Sentry.capture_exception(e)
      raise "Failed to send email: #{Wrapper.error_detail(e)}"
    end

    def remove_grant(nylas_account)
      @client.grants.destroy(grant_id: nylas_account.grant_id)
    end

    def auth_url(organization)
      @client.auth.url_for_oauth2({
        client_id: @config[:client_id],
        redirect_uri: @config[:callback_uri],
        access_type: 'offline',
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

      # Every chunk is appended as binary (`.b`). Otherwise appending UTF-8 text
      # with non-ASCII characters (accents, smart quotes) re-tags the buffer as
      # UTF-8, and the subsequent `File.binread` append raises
      # Encoding::CompatibilityError.
      body = String.new(encoding: 'BINARY')
      body << "--#{boundary}#{crlf}".b
      body << "Content-Disposition: form-data; name=\"message\"#{crlf}".b
      body << "Content-Type: application/json#{crlf}#{crlf}".b
      body << "#{message.to_json}#{crlf}".b
      body << "--#{boundary}#{crlf}".b
      body << "Content-Disposition: form-data; name=\"file0\"; filename=\"#{attachment.name}\"#{crlf}".b
      body << "Content-Type: #{attachment.type}#{crlf}#{crlf}".b
      body << File.binread(attachment.file_path)
      body << "#{crlf}--#{boundary}--#{crlf}".b

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{@config[:api_key]}"
      request['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
      request.body = body

      response = http.request(request)

      raise multipart_send_error(response) unless response.code.to_i == 200

      JSON.parse(response.body)
    end

    # Nylas reports multipart send failures in the response body, shaped like
    # {"request_id": "...", "error": {"type": ..., "message": ..., "provider_error": {...}}}.
    # Rebuild it as the SDK's own error so the real cause survives.
    def multipart_send_error(response)
      status = response.code.to_i
      body = begin
        JSON.parse(response.body)
      rescue JSON::ParserError, TypeError
        nil
      end

      error = body.is_a?(Hash) ? body['error'] : nil
      request_id = body.is_a?(Hash) ? body['request_id'] : nil

      case error
      when Hash
        Nylas::NylasApiError.new(error['type'], error['message'], status,
                                 error['provider_error'], request_id)
      when String
        Nylas::NylasApiError.new('NylasApiError', error, status, nil, request_id)
      else
        message = response.body.presence&.truncate(500) || "HTTP #{status} with no response body"
        Nylas::NylasApiError.new('NylasApiError', message, status, nil, request_id)
      end
    end
  end
end