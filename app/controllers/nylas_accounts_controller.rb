# frozen_string_literal: true

class NylasAccountsController < ApplicationController
  
  def new
    wrapper = Nylas::Wrapper.new

    render json: { url: wrapper.auth_url(OrganizationContext.current_organization) }
  end

  def show
    nylas_account = NylasAccount.find(params[:id])

    nylas_account.refresh_status!

    render json: nylas_account
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def destroy
    nylas_account = NylasAccount.find(params[:id])

    wrapper = Nylas::Wrapper.for(nylas_account)

    wrapper.remove_grant(nylas_account) if !Rails.env.development?
    nylas_account.destroy

    render json: { message: 'Nylas account disconnected successfully.' }
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # Nylas redirects the browser here after hosted auth, on success *and* on
  # failure. Nothing is persisted until we hold a grant_id: every mailer treats
  # the mere presence of an organization's nylas_account as "email is
  # configured", so a half-written row silently breaks outgoing mail.
  def receive_grant
    organization_id, application = Nylas::Wrapper.decode_state(params[:state])
    organization = Organization.find(organization_id)
    code = params[:code]

    # A failed provider leg comes back with error/error_description and no code.
    return redirect_with_email_error(callback_error_message) if code.blank?

    response = Nylas::Wrapper.new(application).exchange_code_for_token(code)
    grant_id = response[:grant_id]

    return redirect_with_email_error('Nylas did not return a grant for this account.') if grant_id.blank?

    nylas_account = organization.nylas_account || organization.build_nylas_account
    nylas_account.update!(
      code: code,
      grant_id: grant_id,
      status: 'active',
      nylas_application: application,
      outgoing_email_address: response[:email],
      raw_response: response
    )

    redirect_to '/admin/company?section=outgoing_email'
  rescue Nylas::AbstractNylasApiError, ActiveRecord::RecordInvalid => e
    Sentry.capture_exception(e)
    redirect_with_email_error(e.message)
  end

  private

  def callback_error_message
    params[:error_description].presence ||
      params[:error].presence ||
      'Authorization was not completed.'
  end

  def redirect_with_email_error(message)
    Rails.logger.warn("[NylasAccounts] grant callback failed: #{message}")

    redirect_to "/admin/company?section=outgoing_email&email_error=#{CGI.escape(message)}"
  end
end