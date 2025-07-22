# frozen_string_literal: true

class NylasAccountsController < ApplicationController
  
  def new
    wrapper = Nylas::Wrapper.new

    render json: { url: wrapper.auth_url }
  end

  def destroy
    nylas_account = NylasAccount.find(params[:id])

    wrapper = Nylas::Wrapper.new

    wrapper.remove_grant(nylas_account) if !Rails.env.development?
    nylas_account.destroy

    render json: { message: 'Nylas account disconnected successfully.' }
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def receive_grant
    nylas_account = Organization.first.nylas_account || NylasAccount.create(organization: Organization.first)
    code = params[:code]

    nylas_account.update(code: code)
    response = Nylas::Wrapper.new.exchange_code_for_token(code)

    grant_id = response[:grant_id]
    email = response[:email]

    nylas_account.update(
      grant_id: grant_id, 
      status: 'active', 
      outgoing_email_address: email, 
      raw_response: response
      )

    redirect_to "https://admin.bigtreeservices.ca/admin/company?section=outgoing_email"
  end
end