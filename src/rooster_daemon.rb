#!/usr/bin/env ruby
# USAGE: 
# 
# ruby lib/rooster/rooster_daemon.rb run     -- start the daemon and stay on top
# ruby lib/rooster/rooster_daemon.rb start   -- start the daemon in the background
# ruby lib/rooster/rooster_daemon.rb stop    -- stop the daemon
# ruby lib/rooster/rooster_daemon.rb restart -- stop the daemon and restart it afterwards


ENV["RAILS_ENV"] ||= "development"
require 'rubygems'
require 'daemons'

ROOT = File.expand_path(File.dirname(__FILE__) + '/../../')
pid_dir = File.join(ROOT, "log")

app_options = { 
  :dir_mode => :normal,
  :dir => pid_dir,
  :multiple => false,
  :backtrace => true,
  :log_output => true
}

Daemons.run_proc("rooster_daemon", app_options) do  
  require File.join(ROOT, "/config/environment")
  require 'rooster'
  
  Rooster::Runner.run
end
