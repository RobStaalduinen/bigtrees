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

    QuoteMailout.post_process_for_type(params[:mail_type], @estimate)

    unless params[:skip]
      if @estimate.customer.email.blank? && params[:mail_type] != QuoteMailout::MAIL_TYPES[:team]
        @estimate.customer.update(email: params[:dest_email])
      end

      QuoteMailer.quote_email(@estimate, params[:dest_email], params[:subject], params[:content]).deliver_now
    end

    if params[:mail_type] == QuoteMailout::MAIL_TYPES[:followup]
      redirect_to estimates_path
    else
      redirect_to estimate_path(@estimate)
    end
  end
end
