# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

 #Rails.application.config.assets.precompile += %w( jquery.modal.min.js )
# ails.application.config.assets.precompile += %w( jquery.modal.js )
# Rails.application.config.assets.precompile += %w( jquery.modal.css )

Dir.glob("#{Rails.root}/app/assets/images/**/").each do |path|
  Rails.application.config.assets.paths << path
end

Rails.application.config.assets.precompile += %w( application_mat.css application_material.css application_boot.css onboarding.js property_management.js )
