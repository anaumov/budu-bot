# frozen_string_literal: true

require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#
require 'capistrano/rbenv'
require 'capistrano/bundler'
require 'capistrano/local_precompile'
require 'capistrano/rails/migrations'
require 'capistrano/puma'
require 'capistrano/rails/console'
require 'capistrano/rails_tail_log'
require 'sshkit/sudo'
# require 'whenever/capistrano'
# require 'capistrano/delayed_job'
require 'capistrano-db-tasks'
# require 'capistrano/sidekiq'
require 'capistrano/shell'

install_plugin Capistrano::Puma
# install_plugin Capistrano::Puma::Monit

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
