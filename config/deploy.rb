# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'r_job'
set :repo_url, 'https://github.com/dchbx/r_job.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/deployments/r_job'
set :rails_env, 'production'

# Default value for :scm is :git
# set :scm, :git
# set :scm, :gitcopy

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug
set :bundle_binstubs, false
set :bundle_flags, "--quiet"
set :bundle_path, nil

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, (fetch(:linked_files, []) | ['config/mongoid.yml', 'config/secrets.yml', "config/environments/production.rb", 'config/unicorn.rb', 'eyes/r_job.eye.rb'])

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'pids', 'eye')

# capistrano/rails setup
set :assets_roles, [:web, :app]

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# FIXME: Fix when assets are generated and linked

namespace :assets do
  desc "Kill all the assets"
  task :refresh do
    on roles(:web) do
#      execute "rm -rf #{shared_path}/public/assets/*"
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "assets:precompile"
        end
      end
    end
  end
end
after "deploy:updated", "assets:refresh"

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 20 do
      sudo "service eye_rails reload"
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end
end

namespace :rocketjob do
  desc 'Start a rocket_job server.'
  task :start do |t, args|
    count   = (ENV['count'] || 1).to_i
    filter  = "--filter #{ENV['filter']}" if ENV['filter']
    workers = "--workers #{ENV['workers']}" if ENV['workers']
    count.times do
      run "cd #{component_path} && nohup bin/rocketjob --quiet #{filter} #{workers} >> #{component_path}/log/rocketjob.log 2>&1 & sleep 2"
    end
  end

  desc 'Stop all rocket_job servers'
  task :stop do |t, args|
    run 'pkill -u rails -f bin/rocketjob'
  end
end


after "deploy:publishing", "deploy:restart"
after "deploy:publishing", "rocketjob:start"

