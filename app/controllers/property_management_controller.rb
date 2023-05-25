# frozen_string_literal: true

class PropertyManagementController < ApplicationController

  def show
    redirect_to '/' unless customer


  end

  def customer
    @customer ||= Customer.find_by(short_name: params[:customer_name])
  end
end
