# config valid for current version and patch releases of Capistrano
lock "~> 3.10.1"

server '159.203.26.93', port: 22, user: 'root', roles: [:web, :app, :db], primary: true

set :application, 'bigtrees'
set :repo_url, 'git@github.com:RobStaalduinen/bigtrees.git'
set :branch, 'master'
set :user, 'root'
set :deploy_to, '/var/www/bigtrees'
set :rbenv_type, :user
set :rbenv_ruby, '2.3.1'

# set :npm_roles, :web
# set :npm_flags, '--silent --no-progress' # by default --production is included but we need devDependencies

set :nc_terminal, 'com.googlecode.iterm2'

# Default value for :linked_files is []
append :linked_files, 'config/application.yml', 'config/database.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'tmp/locks', 'public/system'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5
