# frozen_string_literal: true

set :rails_env, 'production'
set :precompile_env, 'production'
server '134.122.88.210', user: 'wwwbot', roles: %w[app db web]
