# config valid for current version and patch releases of Capistrano
lock "~> 3.10.1"

server '50.17.61.15', port: 22, user: 'ubuntu', roles: [:web, :app, :db], primary: true

set :application, 'bigtrees'
set :repo_url, 'git@github.com:RobStaalduinen/bigtrees.git'
set :branch, 'master'
set :deploy_to, '/var/www/bigtrees'

# set :npm_roles, :web
# set :npm_flags, '--silent --no-progress' # by default --production is included but we need devDependencies

set :nc_terminal, 'com.googlecode.iterm2'

# Default value for :linked_files is []
append :linked_files, 'config/application.yml', 'config/database.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'tmp/locks', 'public/system', 'public/TreeImages'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

set :delayed_job_server_role, :worker
set :delayed_job_workers, 1

after 'deploy:publishing', 'deploy:restart'
# namespace :deploy do
#   task :restart do
#     invoke 'delayed_job:restart'
#   end
# end
