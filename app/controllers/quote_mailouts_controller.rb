class QuoteMailoutsController < ApplicationController
  layout 'admin'

  before_action :signed_in_user

  def new
    @estimate = Estimate.find(params[:estimate_id])

    render template: "quote_mailouts/new/#{params[:mail_type]}"
  end

  def create
    @estimate = Estimate.find(params[:estimate_id])
    @estimate.customer.update(email: params[:dest_email]) if params[:update_email]
    send_email unless params[:skip]
    @estimate.update(estimate_params)

    redirect_to (params[:redirect] || estimate_path(@estimate))
  end

  private

    
    def send_email
      QuoteMailer.quote_email(
        @estimate,
        params[:dest_email],
        params[:subject],
        params[:content]
    ).deliver_now
    end

    def estimate_params
      params.permit(:quote_sent_date, :is_unknown)
    end
end
