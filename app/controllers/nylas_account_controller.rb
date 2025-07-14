# frozen_string_literal: true

class NylasAccountController < ApplicationController
  
  def new
    
  end

  def receive_grant
    code = params[:code]

    puts "Received code: #{code}"
  end
end