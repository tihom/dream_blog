# require 'thinking_sphinx/deploy/capistrano'
# require "delayed/recipes"

# set :whenever_environment, defer { :staging }
# require "whenever/capistrano"

# set :delayed_job_args, "-n 2"

default_run_options[:pty] = true

set :application, "dream_blog"
set :deploy_to, "/var/www/#{application}"
set :user, "root"
set :use_sudo, true

set :scm, :git
set :scm_verbose, true
# set :repository, 'git@github.com:rahulcee/dream_app.git'
set :repository, "/home/mohitagg/dream_blog"

set :branch, "development"
# set :repository_cache, "git_cache"

set :rails_env, 'staging'
set :stage, 'staging'

set :keep_releases, 10


# set :deploy_via, :copy
# set :deploy_via, :rsync_with_remote_cache
# set :rsync_options, "-az --delete -e 'ssh -p 22' --exclude=.git --delete-excluded --verbose" 
# set :git_enable_submodules, 1

# set :domain, "173.255.203.8"
set :vish, "96.126.126.162"
# set :rahu, "50.116.26.227"

role :web, vish
role :app, vish
role :db,  vish, :primary => true # This is where Rails migrations will run

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts


namespace :deploy do
  desc "Copy config files"

  after "deploy:update_code" do
    run "export RAILS_ENV=staging"
    run "ln -nfs #{shared_path}/system #{release_path}/public/system"
    run "ln -nfs #{shared_path}/log #{release_path}/log"
    run "ln -nfs #{shared_path}/tmp #{release_path}/tmp"
    run "ln -nfs #{shared_path}/metrics #{release_path}/public/metrics"

    run "chmod 777 -R #{release_path}/public"
    run "chmod 777 -R #{release_path}/config"

    # run "cp #{shared_path}/config/database.yml #{release_path}/config/"
    # run "cp #{shared_path}/config/environments/staging.rb #{release_path}/config/environments/staging.rb"

    # to copy sitemap from previous version (sitemap should update every day)
    # run "if [ -e #{previous_release}/public/sitemap_index.xml.gz ]; then cp #{previous_release}/public/sitemap* #{current_release}/public/; fi"
  end
 

 #use this if deploying with sitemap for the first time
  # after "deploy" do
  #  run "cd #{latest_release} && rake sitemap:refresh RAILS_ENV=staging"
  # end


  # Passenger stuff
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

end   



after "deploy:restart", "deploy:cleanup" 

#------------
# Database changes  
#------------

namespace :db do

    desc "Seed the database"
    task :db_seed, :roles => :db do
      # on_rollback { deploy.db.restore }
      run "cd #{current_path}"
      run "rake db:seed RAILS_ENV=#{rails_env}"
    end

    desc "Reset the database"
    task :reset, :roles => :db do
      # on_rollback { deploy.db.restore }
      run "cd #{current_path}"
      run "rake db:migrate:reset RAILS_ENV=#{rails_env}"
    end

    desc "Migrate the changes to database"
    task :migrate, :roles => :db do
      run "cd #{current_path}; bundle exec rake db:migrate RAILS_ENV=#{rails_env}"
    end

    desc "Rollback the changes to database"
    task :rollback, :roles => :db do
      run "cd #{current_path}; bundle exec rake db:rollback RAILS_ENV=#{rails_env}"
    end

end



# ==============================
# Uploads
# ==============================

namespace :uploads do

  desc <<-EOD
    Creates the upload folders unless they exist
    and sets the proper upload permissions.
  EOD
  task :setup, :except => { :no_release => true } do
    dirs = uploads_dirs.map { |d| File.join(shared_path, d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
  end

  desc <<-EOD
    [internal] Creates the symlink to uploads shared folder
    for the most recently deployed version.
  EOD
  task :symlink, :except => { :no_release => true } do
    run "rm -rf #{release_path}/public/uploads"
    run "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"
  end

  desc <<-EOD
    [internal] Computes uploads directory paths
    and registers them in Capistrano environment.
  EOD
  task :register_dirs do
    set :uploads_dirs,    %w(uploads) # removed uploads/partners
    set :shared_children, fetch(:shared_children) + fetch(:uploads_dirs)
  end

  after       "deploy:finalize_update", "uploads:symlink"
  on :start,  "uploads:register_dirs"

end