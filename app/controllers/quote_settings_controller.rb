class QuoteSettingsController < ApplicationController
  layout 'admin'

  def show
    authorize Organization, :show?

    render json: quote_settings
  end

  # Upsert — the record is created the first time an organization changes a
  # toggle, not alongside the organization.
  def update
    authorize Organization, :update?

    settings = quote_settings
    settings.update!(quote_settings_params)

    render json: settings
  end

  private

    def organization
      @organization ||= policy_scope(Organization).find(params[:organization_id])
    end

    # Built but unsaved when absent, so #show reports the effective defaults
    # (everything on) rather than null.
    def quote_settings
      settings = organization.quote_settings || organization.build_quote_settings
      # The editor opens on whatever the PDF currently prints, rather than an
      # empty box — the stock copy for anyone who has not customised it.
      settings.footer_text     = organization.default_quote_footer_text if settings.footer_text.nil?
      settings.pre_job_content = QuoteContentDefaults::PRE_JOB if settings.pre_job_content.nil?
      settings.terms_content   = QuoteContentDefaults::TERMS   if settings.terms_content.nil?
      settings
    end

    def quote_settings_params
      params.require(:quote_settings)
            .permit(*QuoteSetting::PAGE_FLAGS, :footer_text, :pre_job_content, :terms_content)
    end
end
