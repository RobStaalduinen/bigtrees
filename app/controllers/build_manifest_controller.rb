class BuildManifestController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  skip_after_action :verify_authorized, raise: false

  MANIFEST_PATH = Rails.root.join("config", "build_manifest.json").freeze

  def show
    if MANIFEST_PATH.exist?
      render json: JSON.parse(MANIFEST_PATH.read)
    else
      render json: { error: "No manifest found" }, status: :not_found
    end
  end
end
