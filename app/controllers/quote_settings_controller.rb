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
      # So the editor opens showing the insurance line it has always printed
      # rather than an empty box, for any organization without a record.
      settings.footer_text = organization.default_quote_footer_text if settings.footer_text.nil?
      settings
    end

    def quote_settings_params
      params.require(:quote_settings).permit(*QuoteSetting::PAGE_FLAGS, :footer_text)
    end
end
