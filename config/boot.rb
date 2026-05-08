ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'logger' # Rails 6 ActiveSupport references Logger without requiring it; concurrent-ruby 1.3.5+ no longer pre-loads it.
