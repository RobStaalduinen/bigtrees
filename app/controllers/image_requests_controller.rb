class ImageRequestsController < AdminBaseController
  before_action :signed_in_user

  def new
    authorize Estimate, :update?

    estimate
  end

  def create
    authorize Estimate, :update?

    if estimate.customer.email.blank?
      estimate.customer.update(email: params[:dest_email])
    end

    QuoteMailer.picture_request(estimate, params[:dest_email], params[:subject], params[:content]).deliver_now

    redirect_to estimate_path(estimate)
  end

  private

  def estimate
    @estimate ||= policy_scope(Estimate).find(params[:estimate_id])
  end

end
