# frozen_string_literal: true

class PropertyManagementController < ApplicationController

  def show
    redirect_to '/' unless customer

    render 'show', layout: 'property_management'
  end

  def create
    Estimate.transaction do
      estimate = Estimate.create(
        organization: Organization.first,
        arborist: Organization.first.arborists.first, # TODO: Update when we have multiple teams
        submission_completed: true,
        customer: customer
      )

      estimate.customer_detail = CustomerDetail.create(customer_detail_params)
      tree = Tree.create(tree_params.merge(estimate_id: estimate.id))

      params[:image_urls]&.each do |image_url|
        TreeImage.create(image_url: image_url, tree_id: tree.id)
      end

      Site.create(site_params.merge(estimate_id: estimate.id))

      tag = Organization.first.tags.find_by(label: 'Property Management')

      estimate.taggings.create(tag: tag) if tag

      render json: {
        estimate_id: estimate&.id,
        tree_id: tree.id
      }, status: 200
    end
  end

  private
  def customer
    @customer ||= Customer.find_by(short_name: params[:customer_name])
  end

  def tree_params
    params.require(:job).permit(:job_type, :description, tree_image: [ :image_url ])
  end

  def site_params
    params.require(:site).permit(
      address_attributes: [ :street ]
    )
  end

  def customer_detail_params
    params.require(:customer_detail).permit(
     :name, :phone, :email
    )
  end
end
