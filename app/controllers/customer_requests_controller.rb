# frozen_string_literal: true

class CustomerRequestsController < ApplicationController
  def new
    render layout: 'onboarding_page'
  end

  def org_scoped
    @organization_shortname = params[:organization_shortname]

    respond_to do |format|
      format.html { render layout: 'white_label' }
    end
  end

  def create
    organization = Organization.find_by(short_name: params[:organization_shortname])

    Estimate.transaction do
      estimate = Estimate.create(organization: organization, submission_completed: true)

      estimate.site_visit_tag = true if params[:site_visit_tag]

      estimate.arborist = organization.default_arborist

      estimate.create_site(site_params)

      customer = Customer.find_or_create_by_params(customer_params)
      estimate.customer = customer

      estimate.create_customer_detail(customer_params)

      tree_params.each do |tree_entry|
        tree = Tree.create(estimate: estimate, **tree_entry.except(:images))

        tree_entry[:images]&.each do |image_url|
          tree.tree_images.create(image_url: image_url, estimate: estimate)
        end
      end

      estimate.save!

      if estimate.persisted?
        EstimateMailer.estimate_alert(estimate).deliver_now


        render json: {
          estimate_id: estimate.id,
          redirect_url: '/main/thank-you-estimate'
        }
      end
    end
  end

  def site_params
    params.require(:site).permit(:wood_removal, :breakables, :low_access_width, :survey_filled_out, :visit_consent, :visit_times, address_attributes: %i[street city])
  end

  def customer_params
    params.require(:customer).permit(:name, :phone, :email)
  end

  def tree_params
    params[:trees].map do |tree|
      tree.permit(:description, :work_type, :stump_removal, images: [])
    end
  end

end
