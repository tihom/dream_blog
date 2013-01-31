require 'capistrano/ext/multistage'
require "bundler/capistrano"

# Add RVM's lib directory to the load path.
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

# Load RVM's capistrano plugin.
#require "rvm/capistrano"

set :stages, %w(development staging production)
set :default_stage, 'development'

#set :rvm_ruby_string, 'ruby-1.9.2-p290'
set :default_environment, {
  #'PATH' => "/usr/local/rvm/gems/ruby-1.9.2-p290/bin:/usr/local/rvm/bin:/usr/local/rvm/gems/ruby-1.9.2-p290/bin:$PATH",
  'PATH' => "/usr/local/rvm/gems/ruby-1.9.2-p290/bin:/usr/local/rvm/bin:$PATH",
  'RUBY_VERSION' => 'ruby 1.9.2',
  'GEM_HOME'     => '/usr/local/rvm/gems/ruby-1.9.2-p290',
  'GEM_PATH'     => '/usr/local/rvm/gems/ruby-1.9.2-p290',
  'BUNDLE_PATH'  => '/usr/local/rvm/gems/ruby-1.9.2-p290'  # If you are using bundler.
}
set :rvm_type, :user  # Don't use system-wide RVM

