require "bundler/capistrano"

set :application, "mosdef"

set :user, "deploy"         # everything on the app server is run as the deploy user
set :jump_user, ENV["USER"] # but this needs to be your own ssh user, may need to specify via `USER=mysshusername cap deploy`
set :use_sudo, false
ssh_options[:forward_agent] = true

set :scm, :git
set :repository, "lti_app_center_git:lti_app_center.git"
set :local_repository, "gerrit.instructure.com:lti_app_center.git"
set :branch, "master"
set :deploy_via, :remote_cache
set :copy_exclude, [".git*"]
set :deploy_to, "/var/web/#{application}"

set :rails_env, "production"
set :bundle_without, [:development, :test]

set :gateway, "#{jump_user}@jump1.prod.us-east-1.insops.net"
role :web, "app1.mosdef-prod.us-east-1.insops.net", "app2.mosdef-prod.us-east-1.insops.net"
role :app, "app1.mosdef-prod.us-east-1.insops.net", "app2.mosdef-prod.us-east-1.insops.net"
role :db, "app1.mosdef-prod.us-east-1.insops.net", :primary => true

after "deploy:restart", "deploy:restart_web"
after "deploy:restart", "deploy:cleanup"
set :keep_releases, 3

namespace :deploy do
  task :restart_web, :roles => :web do
    # apache httpd + passenger module
    run "#{sudo :as => 'root'} /etc/init.d/apache2 reload"
    run "touch #{shared_path}/restart.txt"
  end
end
