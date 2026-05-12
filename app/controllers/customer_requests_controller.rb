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
      estimate = Estimate.new(
        organization: organization,
        submission_completed: true,
        source: :customer_form,
        arborist: organization.default_arborist,
        site_visit: params[:site_visit].present?,
      )

      estimate.build_site(site_params)
      estimate.customer = Customer.find_or_create_by_params(customer_params)
      estimate.build_customer_detail(customer_params)

      tree_params.each do |tree_entry|
        tree = estimate.trees.build(tree_entry.except(:images))

        tree_entry[:images]&.each do |image_url|
          tree.tree_images.build(image_url: image_url, estimate: estimate)
        end
      end

      estimate.save!

      estimate.add_system_tag('Site Visit') if params[:site_visit]

      EstimateMailer.estimate_alert(estimate).deliver_now

      render json: {
        estimate_id: estimate.id,
        redirect_url: '/main/thank-you-estimate'
      }
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
