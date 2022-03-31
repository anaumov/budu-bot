# frozen_string_literal: true

set :rails_env, 'production'
set :precompile_env, 'production'
server '81.163.27.111', user: 'wwwbot', roles: %w[app db web]
