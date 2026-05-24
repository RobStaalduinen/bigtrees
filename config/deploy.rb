# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

ENV['SECRET_KEY_BASE_DUMMY'] ||= '1'

set :application, 'bigtrees'
set :repo_url, 'git@github.com:RobStaalduinen/bigtrees.git'
set :branch, 'master'
set :deploy_to, '/var/www/bigtrees'
set :rvm_map_bins, %w{gem rake ruby rails bundle}
set :rbenv_ruby, '3.3.1'

# Restart Passenger by touching tmp/restart.txt. Avoids the hang at log_revision
# caused by `passenger-config restart-app` holding SSH channel file descriptors.
set :passenger_restart_with_touch, true

# Run `yarn install` on the server before assets:precompile. Shakapacker 7
# no longer auto-installs JS deps during precompile, so wire it in explicitly.
namespace :deploy do
  namespace :assets do
    desc 'Run yarn install on the server'
    task :yarn_install do
      on roles(fetch(:assets_roles, :web)) do
        within release_path do
          execute :yarn, 'install', '--frozen-lockfile', '--production=false'
        end
      end
    end
  end
end
before 'deploy:assets:precompile', 'deploy:assets:yarn_install'

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

after 'deploy:publishing', 'deploy:restart'
after 'deploy:publishing', 'solid_queue:restart'
