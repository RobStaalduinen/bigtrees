# frozen_string_literal: true

class NotesController < ApplicationController

  def create
    note = estimate.notes.new(notes_params)
    note.author = current_user
    note.save

    render json: estimate
  end

  private

  def notes_params
    params.require(:note).permit(
      :content,
      image_attributes: [ :image_url, :edited_url ]
    )
  end

  def estimate
    @estimate ||= Estimate.find(params[:estimate_id])
  end
end
