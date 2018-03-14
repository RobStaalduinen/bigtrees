require 'json'

set :rails_env, :production
set :branch, 'master'
set :user, 'deploy'

# Capistrano DB tasks
# remove remote dump
set :db_remote_clean, true
# exclude tables
set :db_ignore_tables, []
# if you want to work on a specific local environment (default = ENV['RAILS_ENV'] || 'development')
set :local_rails_env, "development"
# if you are highly paranoid and want to prevent any push operation to the server
set :disallow_pushing, false
