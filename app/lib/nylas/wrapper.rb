# frozen_string_literal: true

module Nylas
  class Wrapper
    def initialize
      @config = {
        client_id: ENV['NYLAS_CLIENT_ID'],
        callback_uri: 'https://admin.bigtreeservices.com/nylas_accounts/receive_grant',
        api_key: ENV['NYLAS_API_KEY'],
        api_uri: ENV['NYLAS_API_URI']
      }

      @client = Nylas::Client.new(
        api_key: @config[:api_key],
        api_uri: @config[:api_uri]
      )
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