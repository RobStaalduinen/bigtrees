# frozen_string_literal: true

class TaggingsController < ApplicationController
  def create
    authorize Tagging, :create?

    organization = Organization.find(params[:organization_id])
    tag = organization.tags.find(params[:tag_id])
    estimate = organization.estimates.find(params[:estimate_id])

    Tagging.create(tag: tag, estimate: estimate)

    render json: {}
  end

  def destroy
    authorize Tagging, :destroy?

    organization = Organization.find(params[:organization_id])
    tag = organization.tags.find(params[:tag_id])
    estimate = organization.estimates.find(params[:estimate_id])

    tagging = Tagging.where(tag: tag, estimate: estimate).first
    tagging.destroy

    render json: {}
  end
end