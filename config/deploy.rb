require 'bundler/capistrano'
require File.join(File.dirname(__FILE__), '../lib/capistrano_recipes')

default_environment['PATH'] = '$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH'

set :application, 'fortune_track'
set :repository,  'git@github.com:kirkland/fortune_track.git'

set :scm, :git

role :web, "robmk.com"                          # Your HTTP server, Apache/etc
role :app, "robmk.com"                          # This may be the same as your `Web` server
role :db,  "robmk.com", :primary => true        # This is where Rails migrations will run
role :db,  "robmk.com"

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

before 'deploy:assets:precompile', 'bundle:install'

set :normalize_asset_timestamps, false
