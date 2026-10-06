class QuoteScopesController < ApplicationController
  layout 'admin'

  # Single upsert endpoint: the editor submits all three fields together, and
  # the record is created on first save rather than alongside the estimate.
  def update
    authorize Estimate, :update?

    @estimate = policy_scope(Estimate).find(params[:estimate_id])
    quote_scope = @estimate.quote_scope || @estimate.build_quote_scope

    quote_scope.update!(
      scope_of_work: params[:scope_of_work],
      inclusions: list_param(:inclusions),
      exclusions: list_param(:exclusions)
    )

    render json: @estimate
  end

  private

    # Arrays arrive as ActionController::Parameters when sent as JSON; take the
    # values as plain strings and let the model strip and drop the blanks.
    def list_param(key)
      value = params[key]
      return [] if value.blank?

      Array(value).map(&:to_s)
    end
end
