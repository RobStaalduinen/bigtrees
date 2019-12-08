class QuoteMailoutsController < ApplicationController
  layout 'admin'

  before_action :signed_in_user

  def new
    @estimate = Estimate.find(params[:estimate_id])
    @is_final = params[:is_final] == 'true'

    @mail_type = params[:mail_type]
  end

  def create
    @estimate = Estimate.find(params[:estimate_id])

    unless estimate_params.blank?
      @estimate.update(estimate_params)
    end

    QuoteMailout.post_process_for_type(params[:mail_type], @estimate)

    unless params[:skip]
      if @estimate.email.blank?
        @estimate.update(email: params[:dest_email])
      end

      QuoteMailer.quote_email(@estimate, params[:dest_email], params[:subject], params[:content]).deliver_now
    end

    if params[:mail_type] == QuoteMailout::MAIL_TYPES[:followup]
      redirect_to estimates_path
    else
      redirect_to estimate_path(@estimate)
    end
  end

  private

  def estimate_params
    return {} unless params[:estimate].present?
    params.require(:estimate).permit(:discount_applied, :invoice_number)
  end

end
