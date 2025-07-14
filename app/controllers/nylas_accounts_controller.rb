# frozen_string_literal: true

class NylasAccountsController < ApplicationController
  
  def new
    wrapper = Nylas::Wrapper.new

    render json: { url: wrapper.auth_url }
  end

  def receive_grant
    nylas_account = Organization.first.nylas_account || NylasAccount.create(organization: Organization.first)
    code = params[:code]

    nylas_account.update(code: code)
    response = Nylas::Wrapper.new.exchange_code_for_token(code)

    grant_id = response[:grant_id]

    nylas_account.update(grant_id: grant_id)
    nylas_account.update(raw_response: response)

    puts "Received code: #{code}"
  end
end