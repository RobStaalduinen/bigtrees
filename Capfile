# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Load the SCM plugin appropriate to your project:
#
# require "capistrano/scm/hg"
# install_plugin Capistrano::SCM::Hg
# or
# require "capistrano/scm/svn"
# install_plugin Capistrano::SCM::Svn
# or
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano/passenger'
require 'capistrano/figaro_yml'
require 'capistrano/console'
require 'capistrano/maintenance'
require 'capistrano/delayed_job'
require 'whenever/capistrano'
require 'capistrano/sitemap_generator'


require 'capistrano/rails/console'
require 'capistrano-db-tasks'
require 'capistrano-nc/nc'
require 'capistrano/upload-config'
require 'capistrano/rake'
# require 'capistrano/rbenv'
require 'capistrano/rvm'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
